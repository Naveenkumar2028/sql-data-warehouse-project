# Monthly Sales Growth Analysis

## Purpose

The `monthly_sales_growth.sql` query reports month-over-month revenue performance from `gold.fact_sales`.

## Metrics

- **Total sales:** Sum of sales amount for the calendar month.
- **Previous month sales:** Revenue in the immediately preceding calendar month.
- **Revenue change:** Current month's revenue minus previous month's revenue.
- **Revenue growth (%):** Revenue change divided by previous month's revenue, multiplied by 100.

## Design notes

- `DATEFROMPARTS` normalizes order dates to the first day of each month.
- A recursive calendar CTE fills in missing months between the first and last month with sales; missing-month revenue is set to zero.
- `LAG` compares adjacent calendar months after the calendar has been completed.
- Growth percentage is `NULL` when there is no prior month or the prior month's revenue is zero, avoiding division by zero.

## Validation

Run this query in SQL Server against the project's database and compare a few months with the existing monthly sales summary. The connector can publish the SQL and documentation, but it cannot execute the query against your database, so result-level validation still needs your SQL Server environment.
