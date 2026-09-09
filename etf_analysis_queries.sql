-- ============================================================
-- SQL ETF Market Analysis & Data Pipeline
-- Database: PostgreSQL
-- Author: Alec Morris
-- ============================================================

-- ------------------------------------------------------------
-- DAY 1: Filtering, Sorting & Data Exploration
-- ------------------------------------------------------------

-- Sector Verification
SELECT DISTINCT sector 
FROM etf_prices;

-- Technology Sector Query
SELECT ticker, sector, close 
FROM etf_prices 
WHERE sector = 'Technology' 
LIMIT 10;

-- Column Aliasing & Price Thresholds
SELECT ticker, date, close AS closing_price
FROM etf_prices
WHERE close > 150;

-- Pattern Search
SELECT ticker, sector, volume
FROM etf_prices
WHERE sector LIKE 'P%'
LIMIT 5;

-- Pagination
SELECT ticker, date, volume
FROM etf_prices
WHERE ticker = 'XLF'
LIMIT 5
OFFSET 10;

-- Distinct Pattern Search
SELECT DISTINCT sector 
FROM etf_prices 
WHERE sector LIKE '%Consumer%';

-- Multi-Character Search
SELECT ticker, sector, close 
FROM etf_prices 
WHERE ticker LIKE 'XL%K' 
LIMIT 5;


-- ------------------------------------------------------------
-- DAY 2: Aggregations, Grouping & Order of Execution
-- ------------------------------------------------------------

-- Overall Dataset Metrics
SELECT 
    AVG(close) AS avg_closing_price, 
    MIN(close) AS lowest_closing_price, 
    MAX(close) AS highest_closing_price
FROM etf_prices;

-- Sector Volume Summary
SELECT sector, SUM(volume) AS total_volume
FROM etf_prices 
GROUP BY sector 
ORDER BY total_volume DESC;

-- Record Count Per Ticker
SELECT 
    ticker, 
    COUNT(*) AS total_records
FROM etf_prices
GROUP BY ticker;

-- Group Filtering (HAVING)
SELECT 
    sector, 
    AVG(close) AS avg_closing_price
FROM etf_prices
GROUP BY sector
HAVING AVG(close) > 100;

-- Filtered Group Aggregations
SELECT 
    sector, 
    AVG(volume) AS avg_volume
FROM etf_prices
WHERE sector = 'Technology' OR sector = 'Financials'
GROUP BY sector
ORDER BY avg_volume DESC;


-- ------------------------------------------------------------
-- DAY 3: Expressions, Self-Joins & Null Handling
-- ------------------------------------------------------------

-- Single-Day Price Range Exceeding $2
SELECT date, ticker, sector, (high - low) AS price_range, volume 
FROM etf_prices
WHERE (high - low) > 2
ORDER BY date DESC;

-- Total Cumulative Spread
SELECT ticker, SUM(high - low) AS total_cumulative_spread
FROM etf_prices
GROUP BY ticker
HAVING SUM(high - low) > 500;

-- Identifying Null or Zero Values
SELECT ticker, date, close, volume
FROM etf_prices
WHERE COALESCE(volume, 0) = 0 
   OR COALESCE(close, 0) = 0;

-- Sector Volatility Ranking
SELECT sector, AVG(high - low) AS daily_price_variation
FROM etf_prices
GROUP BY sector
ORDER BY daily_price_variation DESC;

-- Self-Join for Side-by-Side Asset Comparison
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

-- High Volume & Price Sector Filter
SELECT 
    sector, 
    SUM(volume) AS total_volume,  
    AVG(close) AS avg_close 
FROM etf_prices
GROUP BY sector 
HAVING SUM(volume) > 50000000 
   AND AVG(close) > 50;

-- Extreme Percentage Movements
SELECT 
    sector,
    MAX(((close - open) / open) * 100) AS max_daily_gain,
    MIN(((close - open) / open) * 100) AS max_daily_loss
FROM etf_prices
GROUP BY sector
ORDER BY max_daily_gain DESC;


-- ------------------------------------------------------------
-- DAY 4: DDL/DML, Conditional Logic, CTEs & Subqueries
-- ------------------------------------------------------------

-- Full Row Insert
INSERT INTO etf_prices (date, ticker, sector, open, high, low, close, volume)
VALUES ('2026-09-09', 'XLK', 'Technology', 210.00, 215.00, 208.50, 214.00, 25000000);

-- Partial Row Insert
INSERT INTO etf_prices (date, ticker, volume)
VALUES ('2026-09-09', 'XLI', 18000000);

-- Sector Rename Update
UPDATE etf_prices 
SET sector = 'Financial Services' 
WHERE sector = 'Financials';

-- Conditional Price Update
UPDATE etf_prices 
SET close = close * 1.05 
WHERE ticker = 'XLK' 
  AND date = '2026-09-09';

-- Target Row Deletion
DELETE FROM etf_prices 
WHERE date = '2026-09-09'; 

-- Data Sanitization Deletion
DELETE FROM etf_prices 
WHERE close IS NULL OR close <= 0; 

-- Table Creation and Schema Alteration
CREATE TABLE asset_allocation (
    account_id INTEGER PRIMARY KEY, 
    fund_name VARCHAR(50), 
    target_weight NUMERIC
); 

ALTER TABLE asset_allocation 
ADD COLUMN last_reviewed DATE; 

-- Safe Table Removal
DROP TABLE IF EXISTS asset_allocation; 

-- Price Categorization (CASE WHEN)
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

-- Volatility Flagging (CASE WHEN)
SELECT 
    ticker, 
    date, 
    (high - low) AS price_spread,
    CASE 
        WHEN (high - low) > 3.00 THEN 'Volatile'
        ELSE 'Stable'
    END AS volatility_flag
FROM etf_prices;

-- Single-Stage CTE
WITH high_volume_sectors AS (
    SELECT sector, SUM(volume) AS total_volume 
    FROM etf_prices 
    GROUP BY sector 
    HAVING SUM(volume) > 100000000
) 
SELECT sector, total_volume 
FROM high_volume_sectors 
ORDER BY total_volume DESC; 

-- Dual CTE Comparison
WITH tech_prices AS (
    SELECT date, close AS xlk_close 
    FROM etf_prices 
    WHERE ticker = 'XLK'
), 
financial_prices AS (
    SELECT date, close AS xlf_close 
    FROM etf_prices 
    WHERE ticker = 'XLF'
) 
SELECT 
    tech_prices.date, 
    tech_prices.xlk_close, 
    financial_prices.xlf_close 
FROM tech_prices 
JOIN financial_prices ON tech_prices.date = financial_prices.date; 

-- Scalar Subquery in WHERE
SELECT ticker, date, volume 
FROM etf_prices 
WHERE volume > (
    SELECT AVG(volume) 
    FROM etf_prices
); 

-- Multi-Row Subquery with IN
SELECT ticker, date, close, volume 
FROM etf_prices 
WHERE ticker IN (
    SELECT ticker 
    FROM etf_prices 
    GROUP BY ticker 
    HAVING AVG(volume) > 10000000
);