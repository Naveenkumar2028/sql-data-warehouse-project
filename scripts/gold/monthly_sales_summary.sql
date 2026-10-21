/*
===============================================================================
Purpose: Monthly sales summary for the Gold-layer sales fact view.
Grain: One row per calendar month.
Metrics: Order count, units sold, total sales, and average order value.
===============================================================================
*/
WITH monthly_sales AS (
    SELECT
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS sales_month,
        COUNT(DISTINCT order_number) AS order_count,
        SUM(quantity) AS units_sold,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
)
SELECT
    sales_month,
    order_count,
    units_sold,
    total_sales,
    CAST(total_sales / NULLIF(order_count, 0) AS DECIMAL(18, 2)) AS average_order_value
FROM monthly_sales
ORDER BY sales_month;
