
-- Dropping the first column(index column)
-- Repeat for all 4 tables
ALTER TABLE q4_2022_data
DROP COLUMN `Unnamed: 0`;


-- Deleting the first row as it was the header row repeated
-- Repeat for all 4 tables
DELETE FROM q4_2022_data LIMIT 1;


-- Removing any invalid ride_times that may be remaining
-- Repeat for all 4 tables
DELETE
FROM q4_2022_data
WHERE ride_time like '%#%' OR ride_time = '00:00';


-- Rechecking for duplicates and removing
-- Repeat for all 4 tables
SELECT a.*
FROM q4_2022_data AS a
JOIN (SELECT ride_id, COUNT(*)
		FROM q4_2022_data 
		GROUP BY ride_id
		HAVING count(*) > 1 ) AS b
ON a.ride_id = b.ride_id
ORDER BY a.ride_id;


-- Changing weekdays column from numbers to text
-- Repeat for all 4 tables
ALTER TABLE q4_2022_data
MODIFY weekday TEXT;

UPDATE 
	q4_2022_data
SET  
	weekday = 
            CASE
                WHEN weekday = '1' THEN 'Monday'
                WHEN weekday = '2' THEN 'Tuesday'
                WHEN weekday = '3' THEN 'Wednesday'
                WHEN weekday = '4' THEN 'Thursday'
                WHEN weekday = '5' THEN 'Friday'
                WHEN weekday = '6' THEN 'Saturday' 
				WHEN weekday = '7' THEN 'Sunday'
            END
WHERE
        weekday IN ('1', '2', '3', '4', '5', '6', '7'); 


-- Change date and time columns type
-- Repeat for all 4 tables
ALTER TABLE q4_2022_data
MODIFY start_time TIME,
MODIFY end_time TIME,
MODIFY ride_time TIME;

UPDATE q4_2022_data
SET start_date = STR_TO_DATE(start_date, '%d/%m/%Y'),
	end_date = STR_TO_DATE(end_date, '%d/%m/%Y');
ALTER TABLE q4_2022_data
MODIFY start_date DATE,
MODIFY end_date DATE;

UPDATE q4_2022_data
SET started_at = STR_TO_DATE(started_at, '%d/%m/%Y %H:%i'),
	ended_at = STR_TO_DATE(ended_at, '%d/%m/%Y %H:%i');
ALTER TABLE q4_2022_data
MODIFY started_at DATETIME,
MODIFY ended_at DATETIME;

-- Drop valid time from all tables as not needed anymore
-- Repeat for all 4 tables
ALTER TABLE q4_2022_data
DROP COLUMN `valid_time`;


-- Create new table for combined data for all tables, full year data to do general analysis
-- Total of 4,322,763 records combined
CREATE TABLE full_year_data AS
(
SELECT * 
	FROM q1_2023_data
UNION DISTINCT

SELECT * 
	FROM q2_2023_data
UNION DISTINCT

SELECT * 
	FROM q3_2022_data
UNION DISTINCT

SELECT * 
	FROM q4_2022_data
);


-- Adding hour of day column to full_year_data
ALTER TABLE full_year_data
ADD COLUMN hour_of_day INT;
UPDATE full_year_data
SET hour_of_day = HOUR(started_at);


-- Adding month column to full_year_data 
ALTER TABLE full_year_data
ADD COLUMN month INT;
UPDATE full_year_data
SET month = MONTH(started_at);
