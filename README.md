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



