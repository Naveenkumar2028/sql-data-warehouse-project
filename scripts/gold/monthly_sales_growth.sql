/*
===============================================================================
Purpose: Month-over-month sales revenue analysis for the Gold sales fact view.
Grain: One row per calendar month, including months with no recorded sales.
Metrics: Current revenue, previous calendar month's revenue, absolute change,
         and percentage change.
===============================================================================
*/
WITH monthly_sales AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS sales_month,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
),
month_bounds AS (
    SELECT
        MIN(sales_month) AS first_month,
        MAX(sales_month) AS last_month
    FROM monthly_sales
),
calendar_months AS (
    SELECT first_month AS sales_month
    FROM month_bounds
    WHERE first_month IS NOT NULL

    UNION ALL

    SELECT DATEADD(MONTH, 1, calendar_months.sales_month)
    FROM calendar_months
    CROSS JOIN month_bounds
    WHERE calendar_months.sales_month < month_bounds.last_month
),
monthly_revenue AS (
    SELECT
        calendar_months.sales_month,
        COALESCE(monthly_sales.total_sales, 0) AS total_sales
    FROM calendar_months
    LEFT JOIN monthly_sales
        ON monthly_sales.sales_month = calendar_months.sales_month
),
revenue_comparison AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM monthly_revenue
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    total_sales - previous_month_sales AS revenue_change,
    CAST(
        100.0 * (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0)
        AS DECIMAL(10, 2)
    ) AS revenue_growth_percent
FROM revenue_comparison
ORDER BY sales_month
OPTION (MAXRECURSION 0);
