/*
===============================================================================
Purpose: Weekly sales trend and week-over-week growth for the Gold sales view.
Grain: One row per calendar week (Monday through Sunday).
Metrics: Orders, units sold, revenue, prior-week revenue, and growth.
Notes:
    - Empty weeks between the first and last order dates are included as zero.
    - The first week has no prior-week comparison, so growth is NULL.
    - Growth percentage is NULL when prior-week revenue is zero.
===============================================================================
*/
WITH date_bounds AS (
    SELECT
        DATEADD(
            day,
            -(DATEDIFF(day, CONVERT(date, '19000101'), MIN(CAST(order_date AS date))) % 7),
            MIN(CAST(order_date AS date))
        ) AS first_week_start,
        DATEADD(
            day,
            -(DATEDIFF(day, CONVERT(date, '19000101'), MAX(CAST(order_date AS date))) % 7),
            MAX(CAST(order_date AS date))
        ) AS last_week_start
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
),
weekly_sales AS (
    SELECT
        DATEADD(
            day,
            -(DATEDIFF(day, CONVERT(date, '19000101'), CAST(order_date AS date)) % 7),
            CAST(order_date AS date)
        ) AS week_start,
        COUNT(DISTINCT order_number) AS order_count,
        SUM(quantity) AS units_sold,
        CAST(SUM(sales_amount) AS DECIMAL(18, 2)) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY
        DATEADD(
            day,
            -(DATEDIFF(day, CONVERT(date, '19000101'), CAST(order_date AS date)) % 7),
            CAST(order_date AS date)
        )
),
calendar_weeks AS (
    SELECT first_week_start AS week_start
    FROM date_bounds
    WHERE first_week_start IS NOT NULL

    UNION ALL

    SELECT DATEADD(day, 7, calendar_weeks.week_start)
    FROM calendar_weeks
    CROSS JOIN date_bounds
    WHERE DATEADD(day, 7, calendar_weeks.week_start) <= date_bounds.last_week_start
),
weekly_series AS (
    SELECT
        calendar_weeks.week_start,
        COALESCE(weekly_sales.order_count, 0) AS order_count,
        COALESCE(weekly_sales.units_sold, 0) AS units_sold,
        COALESCE(weekly_sales.total_sales, CAST(0 AS DECIMAL(18, 2))) AS total_sales
    FROM calendar_weeks
    LEFT JOIN weekly_sales
        ON calendar_weeks.week_start = weekly_sales.week_start
),
week_comparison AS (
    SELECT
        week_start,
        order_count,
        units_sold,
        total_sales,
        LAG(total_sales) OVER (ORDER BY week_start) AS previous_week_sales
    FROM weekly_series
)
SELECT
    week_start,
    order_count,
    units_sold,
    total_sales,
    previous_week_sales,
    CAST(total_sales - previous_week_sales AS DECIMAL(18, 2)) AS sales_change,
    CAST(
        100.0 * (total_sales - previous_week_sales)
        / NULLIF(previous_week_sales, 0)
        AS DECIMAL(9, 2)
    ) AS sales_growth_pct
FROM week_comparison
ORDER BY week_start
OPTION (MAXRECURSION 0);
