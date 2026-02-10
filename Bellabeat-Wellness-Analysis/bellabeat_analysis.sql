Bellabeat Wellness Analysis (BigQuery SQL)
1. Create cleaned daily activity table

CREATE OR REPLACE TABLE bellabeat_data.daily_activity_clean AS
SELECT DISTINCT
  CAST(Id AS INT64) AS user_id,
  SAFE.PARSE_DATE('%m/%d/%Y', ActivityDate) AS activity_date,
  TotalSteps,
  Calories,
  SedentaryMinutes,
  VeryActiveMinutes
FROM bellabeat_data.daily_activity
WHERE TotalSteps IS NOT NULL;

 2. Create cleaned sleep table

CREATE OR REPLACE TABLE bellabeat_data.sleep_data_clean AS
SELECT DISTINCT
  CAST(Id AS INT64) AS user_id,
  SAFE.PARSE_DATE('%m/%d/%Y', SleepDay) AS sleep_date,
  TotalMinutesAsleep,
  TotalTimeInBed
FROM bellabeat_data.sleep_day
WHERE TotalMinutesAsleep IS NOT NULL;

 3. Join activity and sleep data

CREATE OR REPLACE TABLE bellabeat_data.activity_sleep_joined AS
SELECT
  a.user_id,
  a.activity_date,
  a.TotalSteps,
  a.Calories,
  a.SedentaryMinutes,
  a.VeryActiveMinutes,
  s.TotalMinutesAsleep,
  s.TotalTimeInBed
FROM bellabeat_data.daily_activity_clean a
LEFT JOIN bellabeat_data.sleep_data_clean s
  ON a.user_id = s.user_id
 AND a.activity_date = s.sleep_date;

4. Daily average steps (trend)

SELECT
  activity_date,
  ROUND(AVG(TotalSteps), 0) AS avg_steps
FROM bellabeat_data.activity_sleep_joined
GROUP BY activity_date
ORDER BY activity_date;

5. Calories vs steps (relationship)

SELECT
  TotalSteps,
  Calories
FROM bellabeat_data.activity_sleep_joined
WHERE TotalSteps IS NOT NULL
  AND Calories IS NOT NULL;

6. Average sleep duration by week

SELECT
  FORMAT_DATE('%Y-%V', activity_date) AS year_week,
  ROUND(AVG(TotalMinutesAsleep) / 60, 2) AS avg_sleep_hours
FROM bellabeat_data.activity_sleep_joined
WHERE TotalMinutesAsleep IS NOT NULL
GROUP BY year_week
ORDER BY year_week;

7. Data quality check: rows with sleep tracked

SELECT
  COUNT(*) AS total_rows,
  COUNT(TotalMinutesAsleep) AS rows_with_sleep
FROM bellabeat_data.activity_sleep_joined;

8. User-level average activity and sleep (for segmentation)

SELECT
  user_id,
  ROUND(AVG(TotalSteps), 0) AS avg_daily_steps,
  ROUND(AVG(TotalMinutesAsleep) / 60, 2) AS avg_sleep_hours
FROM bellabeat_data.activity_sleep_joined
GROUP BY user_id
ORDER BY avg_daily_steps DESC;
