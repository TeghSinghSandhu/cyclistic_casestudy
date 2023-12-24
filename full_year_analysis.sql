-- 1) Finding the total number of rides for the quarter, compares cas vs mem and percentage

SELECT
    'Q3 2022' AS quarter,
    COUNT(ride_id) AS total_trips,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_trips,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_trips,
    ROUND((COUNT(CASE WHEN member_casual = 'member' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS member_perc,
    ROUND((COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS casual_perc
FROM q3_2022_data

UNION

SELECT
    'Q4 2022' AS quarter,
    COUNT(ride_id) AS total_trips,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_trips,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_trips,
    ROUND((COUNT(CASE WHEN member_casual = 'member' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS member_perc,
    ROUND((COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS casual_perc
FROM q4_2022_data

UNION 

SELECT
    'Q1 2023' AS quarter,
    COUNT(ride_id) AS total_trips,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_trips,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_trips,
    ROUND((COUNT(CASE WHEN member_casual = 'member' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS member_perc,
    ROUND((COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS casual_perc
FROM q1_2023_data

UNION

SELECT
    'Q2 2023' AS quarter,
    COUNT(ride_id) AS total_trips,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_trips,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_trips,
    ROUND((COUNT(CASE WHEN member_casual = 'member' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS member_perc,
    ROUND((COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS casual_perc
FROM q2_2023_data

UNION

SELECT
    'Full Year' AS quarter,
    COUNT(ride_id) AS total_trips,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) AS member_trips,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) AS casual_trips,
    ROUND((COUNT(CASE WHEN member_casual = 'member' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS member_perc,
    ROUND((COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) / COUNT(ride_id)) * 100, 2) AS casual_perc
FROM full_year_data;


-- 2) Finding the total number of rides for each month in the quarter, compares cas vs mem and percentage
SELECT
	x.*,
    ROUND((member_trips / total_trips) * 100, 2) AS member_perc,
    ROUND((casual_trips / total_trips) * 100, 2) AS casual_perc
FROM (
		SELECT
			MONTH(started_at) AS months,
			COUNT(ride_id) AS total_trips,
					COUNT(CASE
							WHEN member_casual = 'member' 
							THEN 1
							END) AS member_trips,
					COUNT(CASE
							WHEN member_casual = 'casual' 
							THEN 1
							END) AS casual_trips
		FROM full_year_data
		GROUP BY months
        ) AS x
ORDER BY total_trips DESC;


-- 3) Looks at each day of the week and gives the amount of trips taken on each day, compares cas vs mem and percentage
SELECT
    x.*,
    ROUND((member_trips / total_trips) * 100, 2) AS member_perc,
    ROUND((casual_trips / total_trips) * 100, 2) AS casual_perc
FROM (
    SELECT
        weekday,
        COUNT(ride_id) AS total_trips,
        COUNT(CASE
            WHEN member_casual = 'member' 
            THEN 1
            END) AS member_trips,
        COUNT(CASE
            WHEN member_casual = 'casual' 
            THEN 1
            END) AS casual_trips
    FROM full_year_data
    GROUP BY weekday
) AS x
ORDER BY total_trips DESC; 


-- 4) Looks at each hour of the day and also gives the average amount of trips taken during each hour, compares cas vs mem and percentage
SELECT
    x.*,
    ROUND((member_trips / total_trips) * 100, 2) AS member_perc,
    ROUND((casual_trips / total_trips) * 100, 2) AS casual_perc
FROM (
    SELECT
        HOUR(started_at) AS hours_of_day,
        COUNT(ride_id) AS total_trips,
        COUNT(CASE
            WHEN member_casual= 'member' 
            THEN 1
            END) AS member_trips,
        COUNT(CASE
            WHEN member_casual = 'casual' 
            THEN 1
            END) AS casual_trips
    FROM full_year_data
    GROUP BY hours_of_day
) AS x
ORDER BY hours_of_day;


-- 5) Top 10 station ordered by total trips
SELECT 
	DISTINCT start_station_name
    SUM( CASE
		WHEN ride_id = ride_id AND start_station_name = start_station_name 
        THEN 1
        ELSE 0
        END) AS total_trips,
	SUM( CASE
		WHEN member_casual = 'member' AND start_station_name = start_station_name 
        THEN 1
        ELSE 0
        END) AS member_trips,
	SUM( CASE
		WHEN member_casual = 'casual' AND start_station_name = start_station_name 
        THEN 1
        ELSE 0
        END) AS casual_trips
FROM full_year_data
GROUP BY start_station_name     
ORDER BY total_trips DESC
LIMIT 10; 


-- 6) Top Station for each day of the week mem vs cas 
WITH RankedStations AS (
    SELECT
        weekday,
        member_casual AS user_type,
        start_station_name,
        ROW_NUMBER() OVER (PARTITION BY member_casual,  weekday ORDER BY COUNT(*) DESC) AS station_rank
    FROM
        full_year_data
    GROUP BY
        member_casual, weekday, start_station_name
)

SELECT
    weekday,
    user_type,
    start_station_name AS most_popular_station
FROM
    RankedStations
WHERE
    station_rank = 1;


-- 7) Number and percentage of trips per bike and user type							
SELECT
    x.*,
    ROUND((classic_trips / total_trips) * 100, 2) AS classic_perc,
    ROUND((electric_trips / total_trips) * 100, 2) AS electric_perc,
    ROUND((docked_trips / total_trips) * 100, 2) AS docked_perc
FROM (
	SELECT 
		DISTINCT member_casual,
		SUM( CASE
			WHEN ride_id = ride_id AND member_casual = member_casual 
			THEN 1
			ELSE 0
			END) AS total_trips,
		SUM( CASE
			WHEN rideable_type = 'classic_bike' AND member_casual = member_casual 
			THEN 1
			ELSE 0
			END) AS classic_trips,
		SUM( CASE
			WHEN rideable_type = 'electric_bike' AND member_casual = member_casual 
			THEN 1
			ELSE 0
			END) AS electric_trips,
		SUM( CASE
			WHEN rideable_type = 'docked_bike' AND member_casual = member_casual 
			THEN 1
			ELSE 0
			END) AS docked_trips
	FROM full_year_data
	GROUP BY member_casual) AS x
ORDER BY total_trips DESC;


-- 8) Average, Max, Min, Median Ride Times for each bike type 
WITH median_cte AS(
	SELECT
	  rideable_type,
	  SEC_TO_TIME(
		AVG(TIME_TO_SEC(ride_time))
	  ) AS median_ride_time
	FROM (
		  SELECT
			ride_time,
			rideable_type,
			row_num,
			total_rows
		  FROM (				
                SELECT
					ride_time,
					rideable_type,
					ROW_NUMBER() OVER (PARTITION BY rideable_type ORDER BY ride_time) AS row_num,
					COUNT(*) OVER (PARTITION BY rideable_type) AS total_rows
				FROM full_year_data) AS RankedRides
			) AS subquery
	WHERE
	  (total_rows % 2 = 1 AND row_num = (total_rows + 1) / 2) OR
	  (total_rows % 2 = 0 AND (row_num = total_rows / 2 OR row_num = total_rows / 2 + 1))
	GROUP BY
	  rideable_type),

avg_cte AS (
SELECT
rideable_type,
SEC_TO_TIME(
    AVG(TIME_TO_SEC(ride_time))
  ) AS avg_ride_time
FROM full_year_data
GROUP BY rideable_type),

max_min_cte AS (
SELECT 
rideable_type,
MAX(ride_time) AS max_ride,
MIN(ride_time) AS min_ride
FROM full_year_data
GROUP BY rideable_type)

SELECT
	median_cte.rideable_type,
    median_cte.median_ride_time,
    avg_cte.avg_ride_time,
    max_min_cte.max_ride,
    max_min_cte.min_ride
FROM median_cte 
JOIN avg_cte ON median_cte.rideable_type = avg_cte.rideable_type
JOIN max_min_cte ON max_min_cte.rideable_type = avg_cte.rideable_type;


-- 9) Average, Max, Min, Median Ride Times Mem vs Cas 
WITH median_cte AS(
	SELECT
	  member_casual,
	  SEC_TO_TIME(
		AVG(TIME_TO_SEC(ride_time))
	  ) AS median_ride_time
	FROM (
		  SELECT
			ride_time,
			member_casual,
			row_num,
			total_rows
		  FROM (			
				SELECT
					ride_time,
					member_casual,
					ROW_NUMBER() OVER (PARTITION BY member_casual ORDER BY ride_time) AS row_num,
					COUNT(*) OVER (PARTITION BY member_casual) AS total_rows
				FROM full_year_data) AS RankedRides
			) AS subquery
	WHERE
	  (total_rows % 2 = 1 AND row_num = (total_rows + 1) / 2) OR
	  (total_rows % 2 = 0 AND (row_num = total_rows / 2 OR row_num = total_rows / 2 + 1))
	GROUP BY
	  member_casual),

avg_cte AS (
SELECT
member_casual,
SEC_TO_TIME(
    AVG(TIME_TO_SEC(ride_time))
  ) AS avg_ride_time
FROM full_year_data
GROUP BY member_casual),

max_min_cte AS (
SELECT 
member_casual,
MAX(ride_time) AS max_ride,
MIN(ride_time) AS min_ride
FROM full_year_data
GROUP BY member_casual)

SELECT
	median_cte.member_casual,
    median_cte.median_ride_time,
    avg_cte.avg_ride_time,
    max_min_cte.max_ride,
    max_min_cte.min_ride
FROM median_cte 
JOIN avg_cte ON median_cte.member_casual = avg_cte.member_casual
JOIN max_min_cte ON max_min_cte.member_casual = avg_cte.member_casual;


-- 10) Median ride length per week day
WITH RankedRides AS (
	SELECT
    ride_time,
    member_casual,
    weekday,
    ROW_NUMBER() OVER (PARTITION BY member_casual, weekday ORDER BY ride_time) AS row_num,
    COUNT(*) OVER (PARTITION BY member_casual, weekday) AS total_rows
  FROM
    full_year_data)

SELECT
  member_casual,
  weekday,
  SEC_TO_TIME(
    AVG(TIME_TO_SEC(ride_time))
  ) AS median_ride_time
FROM (
  SELECT
    ride_time,
    member_casual,
    weekday,
    row_num,
    total_rows
  FROM
    RankedRides) AS subquery
WHERE
  (total_rows % 2 = 1 AND row_num = (total_rows + 1) / 2) OR
  (total_rows % 2 = 0 AND (row_num = total_rows / 2 OR row_num = total_rows / 2 + 1))
GROUP BY
  member_casual, weekday
ORDER BY member_casual, median_ride_time DESC;


-- 11) Avg ride length per week day
SELECT
member_casual,
weekday,
SEC_TO_TIME(
    AVG(TIME_TO_SEC(ride_time))
  ) AS avg_ride_time
FROM full_year_data
GROUP BY member_casual, weekday
ORDER BY member_casual, avg_ride_time DESC;
