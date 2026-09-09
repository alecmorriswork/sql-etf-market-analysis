ETF Market Analysis & Financial Data Querying (PostgreSQL)

Project Overview
This project demonstrates foundational to intermediate SQL analytics using daily ETF pricing and volume data in PostgreSQL. The objective was to build a structured query suite covering database management, performance metrics, sector volatility, and multi-asset price comparisons.

Key Technical Concepts Demonstrated
* **Data Definition & Manipulation (DDL/DML):** Schema creation (`CREATE TABLE`), conditional record updates, and data sanitization routines.
* **Conditional Logic:** Risk and price tier classification using `CASE WHEN`.
* **Advanced Aggregations:** Sector-level volume tracking, percentage spread calculations, and group filtering with `HAVING`.
* **Multi-Asset Joins & CTEs:** Self-joins and Common Table Expressions (`WITH`) to align concurrent price feeds side-by-side.
* **Subqueries:** Scalar and set-based dynamic filtering (`WHERE ... IN`).

Dataset Structure
`etf_prices` table schema:
* `date` (DATE): Trading date
* `ticker` (VARCHAR): ETF symbol (e.g., XLK, XLF, XLC)
* `sector` (VARCHAR): Market sector
* `open`, `high`, `low`, `close` (NUMERIC): Daily price points
* `volume` (BIGINT): Total shares traded

How to Run
1. Clone this repository or download the files.
2. Import `etf_prices.csv` into your PostgreSQL database via pgAdmin or `psql`.
3. Open `etf_analysis_queries.sql` in pgAdmin and execute queries sequentially.


DAY 1: Select, From, Where, Limit, Offset
1. Sector Filtering: Write a query to return the ticker, sector, and close price for rows where the sector is exactly 'Technology'. Limit your output to 10 rows.

Verify Sector names
SELECT DISTINCT sector 
FROM etf_prices;

Answer Query
SELECT ticker, sector, close 
FROM etf_prices 
WHERE sector = 'Technology' 
LIMIT 10;

2. Column Aliasing & Price Thresholds: Retrieve ticker, date, and close from etf_prices, re-labeling close as closing_price using AS. Filter for rows where the closing price was greater than 150.

Answer Query
SELECT ticker, date, close AS closing_price
FROM etf_prices
WHERE close > 150;

3. Pattern Search (P%): Search for rows where the sector name starts with the letter P (using LIKE 'P%'). Select ticker, sector, and volume, limited to 5 rows.

Answer Query
SELECT ticker, sector, volume
FROM etf_prices
WHERE sector LIKE 'P%'
LIMIT 5;

4. Pagination (OFFSET): Query the ticker, date, and volume for the ticker 'XLF', skip the first 10 rows using OFFSET, and pull the next 5 rows using LIMIT.

Answer Query
SELECT ticker, date, volume
FROM etf_prices
WHERE ticker = ‘XLF’
LIMIT 5
OFFSET 10;
Question 5: Pattern Matching with DISTINCT Write a query to find all unique sector names in etf_prices that contain the word 'Consumer' anywhere in the text.
Answer Query
SELECT DISTINCT sector 
FROM etf_prices 
WHERE sector LIKE '%Consumer%'; 
Question 6: Multi-Character Ticker Search Query the ticker, sector, and close columns for any ETF whose ticker starts with 'XL' and ends with 'K'. Limit the results to 5 rows.
Answer Query
SELECT ticker, sector, close 
FROM etf_prices 
WHERE ticker 
LIKE 'XL%K' LIMIT 5; 

Day 2: Aggregations, Grouping & Order of Execution
Task: Calculate the overall average closing price, lowest closing price, and highest closing price across the entire etf_prices dataset. 
	
SELECT 
    AVG(close) AS avg_closing_price, 
    MIN(close) AS lowest_closing_price, 
    MAX(close) AS highest_closing_price
FROM etf_prices;

Task: Find the total trading volume (SUM(volume)) for each sector. Display the sector name alongside its total volume, ordered from highest volume to lowest. 

SELECT sector, SUM(volume) 
FROM etf_prices 
GROUP BY sector 
ORDER BY SUM(volume) DESC;

Task: Count how many total daily price records (COUNT(*)) exist for each ETF ticker. 

SELECT 
    ticker, 
    COUNT(*) AS total_records
FROM etf_prices
GROUP BY ticker;

Task: Find the average closing price for each sector, but only display sectors where that average closing price is strictly greater than 100 (> 100). 

SELECT 
    sector, 
    AVG(close) AS avg_closing_price
FROM etf_prices
GROUP BY sector
HAVING AVG(close) > 100;

Task: Filter the dataset for rows where the sector is either 'Technology' or 'Financials'. Then, calculate the average volume for each of those two sectors and order the results by average volume descending. 

SELECT 
    sector, 
    AVG(volume) AS avg_volume
FROM etf_prices
WHERE sector = 'Technology' OR sector = 'Financials'
GROUP BY sector
ORDER BY avg_volume DESC;

Day 3: Expressions, Joins & Missing Data
Task 1 a: Pull all trade details and the calculated daily price swing for any record where that single-day price range exceeded two dollars.
SELECT date, ticker, sector, (high - low) AS price_range, volume 
FROM etf_prices
WHERE (high - low) > 2
order by date desc;
Task 1 b: Calculate the total cumulative price spread across all recorded trading days for each ETF ticker, and display only tickers where that total spread exceeds $500. 
SELECT ticker, SUM(high - low) AS total_cumulative_spread
FROM etf_prices
GROUP BY ticker
HAVING SUM(high - low) > 500;
Task 2: Find any records in the dataset that are missing crucial volume or closing price information, along with any days showing zero trading volume.
SELECT ticker, date, close, volume
FROM etf_prices
WHERE COALESCE(volume, 0) 
OR COALESCE(close, 0);

Task 3: Calculate the average daily price variation for every sector and rank them from most volatile to least volatile.
SELECT  sector, AVG(high - low) AS daily_price_variation
FROM etf_prices
GROUP BY sector
ORDER BY daily_price_variation DESC;
Task 4: Join the table to itself on matching dates to compare the daily closing prices of the XLC and XLF tickers side-by-side.
SELECT 
    a.date,
    a.close AS xlc_close,
    b.close AS xlf_close
FROM etf_prices AS a
INNER JOIN etf_prices AS b
    ON a.date = b.date
WHERE a.ticker = 'XLC' 
  AND b.ticker = 'XLF'
ORDER BY a.date ASC;
Task 5: Display the total volume and average close for sectors that accumulated over fifty million in total volume and maintained an average closing price above fifty dollars.
SELECT 
    sector, 
    SUM(volume) AS total_volume,  
    AVG(close) AS avg_close 
FROM etf_prices
GROUP BY sector 
HAVING SUM(volume) > 50000000 
   AND AVG(close) > 50;

Task 6: Determine the largest single-day percentage gain and largest single-day percentage loss recorded within each sector.
SELECT 
    sector,
    MAX(((close - open) / open) * 100) AS max_daily_gain,
    MIN(((close - open) / open) * 100) AS max_daily_loss
FROM etf_prices
GROUP BY sector
ORDER BY max_daily_gain DESC;



Day 4: Conditional Logic, CTEs & Database Management
Part 1: Data Manipulation & Schema Control (DML/DDL)
Task 1: Inserting Full Rows Write an INSERT INTO statement to add a new record to etf_prices for date '2026-09-09', ticker 'XLK', sector 'Technology', open 210.00, high 215.00, low 208.50, close 214.00, and volume 25000000.
INSERT INTO etf_prices (date, ticker, sector, open, high, low, close, volume)
VALUES ('2026-09-09', 'XLK', 'Technology', 210.00, 215.00, 208.50, 214.00, 25000000);
Task 2: Partial Row Insertion Insert a new record into etf_prices specifying only the date, ticker, and volume ('2026-09-09', 'XLI', 18000000), letting all other columns default to NULL.
INSERT INTO etf_prices (date, ticker, volume)
VALUES ('2026-09-09', 'XLI', 18000000);
Task 3: Updating Grouped Text Records Write an UPDATE query to rename the sector 'Financials' to 'Financial Services' across all records in etf_prices.
UPDATE etf_prices 
SET sector = 'Financial Services' 
WHERE sector = 'Financials';
Task 4: Conditional Numeric Update Write an UPDATE query to increase the close price by 5% (close = close * 1.05) for all rows where the ticker is 'XLK' and the date is '2026-09-09'.
UPDATE etf_prices 
SET close = close * 1.05 
WHERE ticker = 'XLK' 
  AND date = '2026-09-09';
Task 5: Target Deletion by Date Write a DELETE statement to remove all test records from etf_prices where the date is '2026-09-09'.
DELETE FROM etf_prices WHERE date = '2026-09-09'; 
Task 6: Data Cleanup Deletion Write a DELETE statement to remove any rows in etf_prices where close is NULL or close <= 0.
DELETE FROM etf_prices WHERE close IS NULL OR close <= 0; 
Task 7: Creating & Altering Tables Write a query to create a table named asset_allocations with three columns: account_id (INTEGER PRIMARY KEY), fund_name (VARCHAR(50)), and target_weight (NUMERIC). Then, write a second query to add a column named last_reviewed with the data type DATE to this table. 
CREATE TABLE asset_allocation ( account_id INTEGER PRIMARY KEY, fund_name VARCHAR(50), target_weight NUMERIC ); 
ALTER TABLE asset_allocation ADD COLUMN last_reviewed DATE; 
Task 8: Dropping Tables Safely Write a query to safely delete the asset_allocations table from your database if it exists. 
DROP TABLE IF EXISTS asset_allocation; 
Part 2: Advanced Logic & Analytics
Task 9: Conditional Categorization (CASE WHEN) Select ticker, date, close, and use a CASE WHEN expression to create a column named price_tier:
'High' if close > 150
'Mid' if close BETWEEN 50 AND 150
'Low' if close < 50
SELECT 
    ticker, 
    date, 
    close,
    CASE 
        WHEN close > 150 THEN 'High'
        WHEN close BETWEEN 50 AND 150 THEN 'Mid'
        WHEN close < 50 THEN 'Low'
    END AS price_tier
FROM etf_prices;
Task 10: Volatility Classification (CASE WHEN) Calculate the daily price range (high - low). Use CASE WHEN to label the row as 'Volatile' if (high - low) > 3.00, and 'Stable' otherwise. Return ticker, date, (high - low) AS price_spread, and volatility_flag.
SELECT 
    ticker, 
    date, 
    (high - low) AS price_spread,
    CASE 
        WHEN (high - low) > 3.00 THEN 'Volatile'
        ELSE 'Stable'
    END AS volatility_flag
FROM etf_prices;

Task 11: Single-Stage CTE (WITH) Write a CTE named high_volume_sectors that finds all sectors where SUM(volume) > 100000000. In your main query, select sector and total_volume from the CTE and order by total volume descending.
WITH high_volume_sectors AS ( SELECT sector, SUM(volume) AS total_volume FROM etf_prices GROUP BY sector HAVING SUM(volume) > 100000000 ) 
SELECT sector, total_volume FROM high_volume_sectors ORDER BY total_volume DESC; 

Task 12: Dual CTE Comparison (WITH) Create a CTE named tech_prices pulling date and close for ticker 'XLK'. Create a second CTE named financial_prices pulling date and close for ticker 'XLF'. In your main query, join them on date to display xlk_close and xlf_close side-by-side.
WITH tech_prices AS ( SELECT date, close AS xlk_close FROM etf_prices WHERE ticker = 'XLK' ), financial_prices AS ( SELECT date, close AS xlf_close FROM etf_prices WHERE ticker = 'XLF' ) 
SELECT tech_prices.date, tech_prices.xlk_close, financial_prices.xlf_close FROM tech_prices JOIN financial_prices ON tech_prices.date = financial_prices.date; 
Part 3: Subqueries
Task 13: Scalar Subquery in WHERE Write a query to select ticker, date, and volume for all trading days where volume was strictly greater than the average daily volume across the entire dataset.
SELECT ticker, date, volume FROM etf_prices WHERE volume > ( SELECT AVG(volume) FROM etf_prices ); 
Task 14: Filtering with IN Subqueries Write a query to return ticker, sector, and close for all ETFs that belong to sectors whose average closing price is greater than $100.
SELECT ticker, date, close, volume FROM etf_prices WHERE ticker IN ( SELECT ticker FROM etf_prices GROUP BY ticker HAVING AVG(volume) > 10000000 ); 


