CREATE DATABASE NYC_TAXI_DB;

USE DATABASE NYC_TAXI_DB;

CREATE SCHEMA NYC_SCHEMA;

USE SCHEMA NYC_SCHEMA;

SELECT CURRENT_DATABASE(),CURRENT_SCHEMA()

CREATE OR REPLACE TABLE TRIPS (
    VendorID              INT,
    tpep_pickup_datetime  TIMESTAMP_NTZ,
    tpep_dropoff_datetime TIMESTAMP_NTZ,
    passenger_count       FLOAT,
    trip_distance         FLOAT,
    RATECODEID            FLOAT,
    store_and_fwd_flag    VARCHAR(5),
    PULocationID          INT,
    DOLocationID          INT,
    payment_type          INT,
    fare_amount           FLOAT,
    extra                 FLOAT,
    mta_tax               FLOAT,
    tip_amount            FLOAT,
    tolls_amount          FLOAT,
    improvement_surcharge FLOAT,
    total_amount          FLOAT,
    congestion_surcharge  FLOAT
);

CREATE OR REPLACE FILE FORMAT NYC_TAXI
TYPE = 'PARQUET'
USE_LOGICAL_TYPE = TRUE     
SNAPPY_COMPRESSION = TRUE
BINARY_AS_TEXT = FALSE;
    
CREATE OR REPLACE STAGE NYC_TAXI_STAGE 
FILE_FORMAT = NYC_TAXI

LIST @NYC_TAXI_STAGE;

COPY INTO NYC_SCHEMA.TRIPS 
FROM  @NYC_TAXI_STAGE
FILE_FORMAT = (FORMAT_NAME = 'NYC_TAXI'
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
FORCE = TRUE;

SELECT * FROM TRIPS

SELECT COUNT(*) FROM TRIPS

SELECT YEAR(tpep_pickup_datetime)AS YEAR,
COUNT(*)AS TOTAL_TRIPS
FROM TRIPS
GROUP BY 1
ORDER BY 1

CREATE OR REPLACE VIEW TRIPS_CLEAN AS
SELECT 
    VENDORID,
    TPEP_PICKUP_DATETIME,
    TPEP_DROPOFF_DATETIME,
    COALESCE(PASSENGER_COUNT, 0)        AS PASSENGER_COUNT,
    TRIP_DISTANCE,
    COALESCE(RATECODEID, 0)             AS RATECODEID,
    COALESCE(STORE_AND_FWD_FLAG, 'N')   AS STORE_AND_FWD_FLAG,
    PULOCATIONID,
    DOLOCATIONID,
    PAYMENT_TYPE,
    FARE_AMOUNT,
    EXTRA,
    MTA_TAX,
    TIP_AMOUNT,
    TOLLS_AMOUNT,
    IMPROVEMENT_SURCHARGE,
    TOTAL_AMOUNT,
    COALESCE(CONGESTION_SURCHARGE, 0)   AS CONGESTION_SURCHARGE,
CASE 
WHEN PAYMENT_TYPE = 1 THEN 'CREDIT CARD'
WHEN PAYMENT_TYPE = 2 THEN 'CASH'
WHEN PAYMENT_TYPE = 3 THEN 'NO CHARGE'
WHEN PAYMENT_TYPE = 4 THEN 'DISPUTE'
WHEN PAYMENT_TYPE = 5 THEN 'UNKNOWN'
WHEN PAYMENT_TYPE = 0 THEN 'UNKNOWN/NOT RECORDED'
END AS PAYMENT_CATEGORY
FROM TRIPS
WHERE YEAR(tpep_pickup_datetime) IN (2021,2022,2023)
AND TIP_AMOUNT BETWEEN 0 AND 200
AND FARE_AMOUNT BETWEEN 1 AND 500
AND TRIP_DISTANCE  BETWEEN  0.1 AND 100;


CREATE OR REPLACE TABLE TAXI_ZONE_LOOKUP(
    LOCATIONID INT,
    BOROUGH STRING,
    ZONE STRING,
    SERVICE_ZONE STRING
);

-- DATA CLEANING DECISIONS:
-- 1. NULL passenger_count  → replaced with 0
--    (trip happened, passenger count unknown)
-- 2. NULL ratecodeid       → replaced with 0
--    (unknown rate applied)
-- 3. NULL store_and_fwd    → replaced with 'N'
--    (assumed direct server connection)
-- 4. NULL congestion       → replaced with 0
--    (no surcharge applied)
-- 5. tip > $200            → removed (fraud/error)
-- 6. fare < $1 or > $500   → removed (invalid)
-- 7. distance < 0.1        → removed (ghost trips)
-- Remaining rows after cleaning: 106140252


🏢 Business Context

You are a Data Analyst at NYC Taxi & Limousine Commission. Management has asked you to analyze 10.8 Crore trips and answer these business questions:

Q1. What is the total trips and total revenue 
    generated each year (2021, 2022, 2023)?
    → Management wants to see YoY growth!

SELECT YEAR,TOTAL_TRIPS,TOTAL_REVENUE,
ROUND(
((TOTAL_REVENUE - LAG(TOTAL_REVENUE)OVER(ORDER BY YEAR)) / LAG(TOTAL_REVENUE)OVER(ORDER BY YEAR))*100,2)AS YOY_GROWTH_PCT
FROM (
    SELECT YEAR(tpep_pickup_datetime)AS YEAR,
    COUNT(*)AS TOTAL_TRIPS,SUM(TOTAL_AMOUNT)AS TOTAL_REVENUE 
    FROM TRIPS_CLEAN
    GROUP BY 1
    )
    ORDER BY 1

    -- INSIGHT Q1:
-- Revenue grew 79% from 2021 to 2023 ($608M → $1.09B)
-- 2022 showed strongest growth (+41%) = post-COVID recovery
-- 2023 revenue crossed $1 Billion despite fewer trips
-- Fare increases drove revenue even with lower trip volume.

Q2: What is the average fare, average tip 
    and average trip distance per year?
→ Finance team needs pricing insights!

SELECT YEAR(tpep_pickup_datetime)AS YEAR,
ROUND(AVG(FARE_AMOUNT),2)AS AVG_FARE,ROUND(AVG(TIP_AMOUNT),2)AS AVG_TIP,
ROUND(AVG(TRIP_DISTANCE),2)AS AVG_TRIP_DISTANCE 
FROM TRIPS_CLEAN
GROUP BY 1
ORDER BY 1

-- INSIGHT Q2:
-- Average fare increased 47% (2021-2023)
-- Trip distance stable at ~3.5 miles consistently
-- Tips grew 53% showing improved passenger satisfaction
-- 2022 tip outliers successfully removed by cleaning

Q3: Which year had highest revenue PER TRIP?
    (Total Revenue ÷ Total Trips = Revenue per trip)
→ Which year was most profitable per ride?

SELECT YEAR(tpep_pickup_datetime)AS YEAR,ROUND(SUM(TOTAL_AMOUNT)/ COUNT(*),2) AS REVENUE_PER_TRIP
FROM TRIPS_CLEAN 
GROUP BY 1
ORDER BY 1

-- INSIGHT Q3:
-- Revenue per trip grew 47% from $19.70 to $28.91
-- 2023 most profitable year per ride
-- Fare hikes + shorter trips = higher revenue efficiency

Q4: What is month-wise trip count for each year?
→ Operations team needs seasonal planning!

SELECT TO_CHAR(tpep_pickup_datetime,'YY-MM')as MONTH_DATE,
COUNT(*)AS TRIP_COUNT
FROM TRIPS_CLEAN
GROUP BY 1
ORDER BY 1

-- INSIGHT Q4:
-- Jan 2021 lowest ever (1.34M) = COVID impact
-- Oct 2022 highest ever (3.57M) = Peak recovery
-- Clear seasonal pattern: Jan low, Oct high
-- 2021 showed 135% growth Jan→Dec = recovery story

Q5: Which hour of the day has highest 
    number of trips across all 3 years?
→ Driver scheduling optimization!

SELECT HOUR(tpep_pickup_datetime)AS HOUR,
COUNT(*)AS TOTAL_TRIPS 
FROM TRIPS_CLEAN
GROUP BY 1
ORDER BY 1

-- INSIGHT Q5:
-- Peak hour = 6 PM with 7.5M trips (3 year total)
-- Evening rush 63% busier than morning rush
-- Consistent demand 10AM-8PM = 10 hour peak window
-- Minimum demand at 4 AM = driver rest period
-- Recommendation: Maximum drivers deployed 5PM-8PM

Q6: Which day of week generates 
    highest revenue?
→ Weekly demand pattern!


SELECT DAYNAME(tpep_pickup_datetime)AS DAY,
SUM(TOTAL_AMOUNT)AS REVENUE,
DENSE_RANK() OVER(ORDER BY REVENUE DESC)AS RANK_NUM
FROM TRIPS_CLEAN 
GROUP BY 1

-- INSIGHT Q6:
-- Thursday = highest revenue day ($394.9M)
-- Mid-week (Wed-Thu-Fri) generates $1.15B combined
-- Weekends surprisingly lower than weekdays
-- Sunday = lowest revenue ($312.7M)
-- Business travel drives premium weekday revenue

Q7: What percentage of trips happen 
    during rush hours?
    Morning Rush = 7AM to 10AM
    Evening Rush = 5PM to 8PM
→ Rush hour impact on business!

SELECT RUSH_HOUR_TYPE,
COUNT(*)AS TOTAL_TRIPS,
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2)AS PERCENTAGE
FROM(
SELECT CASE
WHEN HOUR(tpep_pickup_datetime) BETWEEN 7 AND 10 
THEN 'MORNING RUSH (7-10 AM)'
WHEN HOUR(tpep_pickup_datetime) BETWEEN 17 AND 20 
THEN 'EVENING RUSH (5-8 PM)'
ELSE 'NORMAL HOURS'
END AS RUSH_HOUR_TYPE
FROM TRIPS_CLEAN
)
GROUP BY 1
ORDER BY TOTAL_TRIPS DESC;

-- INSIGHT Q7:
-- Rush hours generate 41.59% of all trips
-- in only 25% of the day (6 out of 24 hours)
-- Evening rush (25.71%) > Morning rush (15.88%)
-- Recommendation: Surge pricing during rush hours
-- can significantly increase revenue!

Q8: How many trips happen late night 
    (12AM to 5AM) vs daytime?
→ Night shift driver requirement!


SELECT TRIPS_CATEGORY,COUNT(*)AS TOTAL_TRIPS 
FROM (
SELECT CASE 
WHEN HOUR(tpep_pickup_datetime) BETWEEN 0 AND 5
THEN 'LATE_NIGHT_TRIPS'
WHEN HOUR(tpep_pickup_datetime) BETWEEN 6 AND 23 
THEN 'DAYTIME_TRIPS'
END AS TRIPS_CATEGORY
FROM TRIPS_CLEAN
)
GROUP BY 1
ORDER BY 2 DESC

-- Out of 106 million total trips, 92.7% occur during daytime (6AM–11PM) and only 7.3% occur during late night hours (12AM–5AM). Despite the lower volume, late night trips still account for 7.7 million rides, indicating a consistent demand even during off-peak hours.

Q9. What is the split between Cash vs 
    Credit Card payments each year?
    → Payment trend analysis!

SELECT YEAR(TPEP_PICKUP_DATETIME)AS YEAR,
CASE 
WHEN PAYMENT_TYPE = 1 THEN 'CREDIT CARD'
WHEN PAYMENT_TYPE = 2 THEN 'CASH'
ELSE 'OTHER'
END AS PAYMENT_METHOD,
COUNT(*)AS TOTAL_TRIPS,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*))OVER(PARTITION BY YEAR(TPEP_PICKUP_DATETIME)),2)AS PERCENTAGE
FROM TRIPS_CLEAN 
GROUP BY 1,2 
ORDER BY 1,3

  -- Insight:
-- Credit card payments have been consistently dominant and growing every year — rising from 73.37% in 2021 to 79.73% in 2023, an increase of +6.36 percentage points in just 2 years. Meanwhile, cash payments have steadily declined from 21.41% to just 16.59%, a drop of nearly 5 percentage points. "Other" payment methods also declined slightly from 5.23% to 3.68%, suggesting passengers are consolidating toward card payments rather than alternative methods.

Q10. Do credit card users tip more than 
     cash users? What is average tip 
     for each payment type?
     → Driver earnings insight!

SELECT PAYMENT_METHOD,
ROUND(AVG(TIP_AMOUNT),2)AS AVG_TIP_AMOUNT
FROM (
     SELECT TIP_AMOUNT,
     CASE 
     WHEN PAYMENT_TYPE = 1 THEN 'CREDIT_CARD_USERS'
     WHEN PAYMENT_TYPE = 2 THEN 'CASH_USERS'
     ELSE 'OTHER'
     END AS PAYMENT_METHOD 
     FROM TRIPS_CLEAN
     )
     GROUP BY 1
     ORDER BY 2 DESC;

--Insight:
--Credit card users tip an average of $3.68 per trip, which is fully captured digitally. Cash users show $0.00 in the dataset — not because they don't tip, but because cash tips are handed directly to drivers and never entered into the system. This is a well-known data limitation in NYC taxi datasets. With 79.73% of passengers paying by card in 2023, the majority of recorded tip income now comes from digital payments, making credit card trips significantly more transparent and trackable for driver earnings analysis.

Q11. What are the top 5 most expensive 
     routes by average fare amount?
     → Identify premium routes!

SELECT ROUTE,AVG_FARE_AMOUNT FROM (
     SELECT CONCAT(P.ZONE,' -> ',D.ZONE)AS ROUTE,
     AVG(FARE_AMOUNT)AS AVG_FARE_AMOUNT,
     DENSE_RANK() OVER(ORDER BY AVG(FARE_AMOUNT)DESC)AS RANK_NUM
     FROM TRIPS_CLEAN T
     LEFT JOIN TAXI_ZONE_LOOKUP P 
     ON T.PULOCATIONID=P.LOCATIONID
     LEFT JOIN TAXI_ZONE_LOOKUP D
     ON T.DOLOCATIONID=D.LOCATIONID
     GROUP BY 1
     )
     WHERE RANK_NUM <= 5

     --INSIGHT:

--• Newark Airport → West Concourse had the highest average fare (~$420).

--• Airport-related routes generally show higher fare values.

--• Longer-distance routes tend to generate premium pricing.

--• Route averages should be interpreted with trip counts because low-frequency routes can inflate averages.


Q12. What percentage of trips have 
     zero tip amount?
     → Tip behavior analysis!

    SELECT 
   ROUND(
   (COUNT(CASE WHEN TIP_AMOUNT = 0 THEN 1 END)*100.0)/COUNT(*),2)AS ZERO_TRIP_PERCENTAGE
   FROM TRIPS_CLEAN

 --INSIGHT:  23.61% of all NYC taxi trips — roughly 25 million rides — recorded zero tip amount. However, this figure must be interpreted carefully. As established in Q10, all cash trips record $0.00 tip by default since cash tips are handed directly to drivers and never entered into the system. Cash payments account for ~16–21% of trips across 2021–2023, which largely explains the 23.61% zero tip figure. The true zero-tip rate among card users is likely much lower, making this a data quality observation as much as a behavioral one.

 Q13. What are the top 10 most popular 
     pickup locations (PULocationID)?
     → Where do most trips start?

     SELECT PICKUP_LOCATION,TOTAL_TRIPS
     FROM (
SELECT P.ZONE AS PICKUP_LOCATION,
COUNT(*)AS TOTAL_TRIPS,
DENSE_RANK() OVER(ORDER BY COUNT(*)DESC)AS RANK_NUM
FROM TRIPS_CLEAN T
LEFT JOIN TAXI_ZONE_LOOKUP P 
ON T.PULOCATIONID=P.LOCATIONID
GROUP BY 1
     )
     WHERE RANK_NUM <=10

--• Upper East Side South recorded the highest pickup volume with more than 5.1 million trips, making it the most active trip origin area.

--• Midtown Center, Times Square/Theatre District, and Penn Station appear among the top pickup locations, indicating strong demand in commercial and tourist hubs.

--• JFK Airport is one of the busiest pickup zones, reflecting significant airport-related transportation demand.

--• Most high-demand pickup locations are concentrated in Manhattan, suggesting dense passenger activity and business movement.

--• Pickup demand is heavily concentrated in a few zones, which can help optimize taxi fleet allocation and reduce passenger wait times.

Q14. What are the top 10 most popular 
     dropoff locations (DOLocationID)?
     → Where do most trips end?

     
     SELECT DROP_LOCATION,TOTAL_TRIPS
     FROM (
SELECT D.ZONE AS DROP_LOCATION,
COUNT(*)AS TOTAL_TRIPS,
DENSE_RANK() OVER(ORDER BY COUNT(*)DESC)AS RANK_NUM
FROM TRIPS_CLEAN T
LEFT JOIN TAXI_ZONE_LOOKUP D 
ON T.DOLOCATIONID=D.LOCATIONID
GROUP BY 1
     )
     WHERE RANK_NUM <=10

--Insight:
-- Upper East Side North recorded the highest drop-off volume with approximately 4.7 million trips, making it the most frequent destination area.

-- Midtown Center, Times Square/Theatre District, and Midtown East appear among the top drop locations, indicating strong activity in commercial and business districts.

-- Most high-volume drop-off locations are concentrated in Manhattan, reflecting dense passenger movement across major city zones.

-- Popular residential and commercial areas receive a significant share of taxi traffic, suggesting recurring commuter and tourist travel patterns.

-- Understanding destination hotspots can help improve fleet positioning and support demand forecasting.

Q15. Which pickup-dropoff combination 
     (route) is most common?
     → Most popular route in NYC!

      SELECT CONCAT(P.ZONE,' -> ',D.ZONE)AS ROUTE,
      COUNT(*)AS TOTAL_TRIPS
      FROM TRIPS_CLEAN T 
      JOIN TAXI_ZONE_LOOKUP P 
      ON T.PULOCATIONID=P.LOCATIONID
      LEFT JOIN TAXI_ZONE_LOOKUP D 
      ON T.DOLOCATIONID=D.LOCATIONID
      GROUP BY 1
      ORDER BY 2 DESC 
      LIMIT 1

--INSIGHT:
--The route from Upper East Side South → Upper East Side North was the most frequently traveled route, with approximately 738K trips.

-- High trip volume between nearby Manhattan zones suggests strong recurring local travel demand.

--Frequent travel between neighboring areas may indicate daily commuting, shopping activity, and short-distance passenger movement.

--Manhattan zones dominate both pickup and drop-off patterns, showing concentrated transportation activity in central city areas.

--Identifying high-demand routes can help optimize taxi availability and improve fleet allocation.

 Q16. What is the average trip distance 
     for each pickup location (top 10)?
     → Which zones have longest trips?

     
SELECT PICKUP_LOCATION,AVG_TRIP_DISTANCE
FROM (
SELECT P.ZONE AS PICKUP_LOCATION,
ROUND(AVG(TRIP_DISTANCE),2)AS AVG_TRIP_DISTANCE,
DENSE_RANK() OVER(ORDER BY AVG(TRIP_DISTANCE) DESC)AS RANK_NUM
FROM TRIPS_CLEAN T 
LEFT JOIN TAXI_ZONE_LOOKUP P 
ON T.PULOCATIONID=P.LOCATIONID
GROUP BY 1
)
WHERE RANK_NUM <= 10

--INSIGHT:
--Charleston/Tottenville recorded the highest average trip distance (~33 miles), indicating that trips originating from this area are generally long-distance journeys.

--Most zones with high average trip distances are located in outer borough or suburban areas, suggesting passengers travel farther to reach business and city centers.

--Peripheral locations such as Staten Island and park areas show longer travel patterns compared to central Manhattan zones.

--Long-distance pickup zones may generate higher fare values and contribute significantly to revenue despite lower trip volumes.

--Understanding zones with longer average trip distances can help identify premium travel segments and optimize pricing strategies.

CREATE OR REPLACE VIEW MASTER_ANALYTICS AS

SELECT

T.VENDORID,

T.TPEP_PICKUP_DATETIME,
T.TPEP_DROPOFF_DATETIME,

YEAR(T.TPEP_PICKUP_DATETIME) AS YEAR,
MONTH(T.TPEP_PICKUP_DATETIME) AS MONTH_NO,
MONTHNAME(T.TPEP_PICKUP_DATETIME) AS MONTH_NAME,
DAYNAME(T.TPEP_PICKUP_DATETIME) AS DAY_NAME,
HOUR(T.TPEP_PICKUP_DATETIME) AS HOUR,

T.PASSENGER_COUNT,
T.TRIP_DISTANCE,

T.FARE_AMOUNT,
T.TIP_AMOUNT,
T.TOTAL_AMOUNT,

T.PAYMENT_CATEGORY,

P.BOROUGH AS PICKUP_BOROUGH,
P.ZONE AS PICKUP_ZONE,

D.BOROUGH AS DROPOFF_BOROUGH,
D.ZONE AS DROPOFF_ZONE,

CONCAT(
P.ZONE,
' -> ',
D.ZONE
) AS ROUTE,

CASE
WHEN HOUR(T.TPEP_PICKUP_DATETIME)
BETWEEN 7 AND 10
THEN 'MORNING RUSH'

WHEN HOUR(T.TPEP_PICKUP_DATETIME)
BETWEEN 17 AND 20
THEN 'EVENING RUSH'

ELSE 'NORMAL HOURS'
END AS RUSH_TYPE,

CASE
WHEN HOUR(T.TPEP_PICKUP_DATETIME)
BETWEEN 0 AND 5
THEN 'LATE NIGHT'

ELSE 'DAYTIME'
END AS TRIP_CATEGORY,

CASE

WHEN T.TRIP_DISTANCE <3
THEN 'SHORT TRIP'

WHEN T.TRIP_DISTANCE <10
THEN 'MEDIUM TRIP'

ELSE 'LONG TRIP'

END AS TRIP_SEGMENT,

ROUND(
T.TOTAL_AMOUNT/
NULLIF(T.TRIP_DISTANCE,0),
2
) AS REVENUE_PER_MILE

FROM TRIPS_CLEAN T

LEFT JOIN TAXI_ZONE_LOOKUP P
ON T.PULOCATIONID=P.LOCATIONID

LEFT JOIN TAXI_ZONE_LOOKUP D
ON T.DOLOCATIONID=D.LOCATIONID;

select * from MASTER_ANALYTICS


Select * from MASTER_ANALYTICS