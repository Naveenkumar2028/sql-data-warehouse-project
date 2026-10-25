/*
Top products by revenue
-----------------------
SQL Server / T-SQL analytics query.

Expected Gold-layer columns:
  gold.fact_sales: product_key, sales_amount, order_number, quantity
  gold.dim_products: product_key, product_name

Business use:
  - Rank products by revenue.
  - Show order volume and units sold.
  - Calculate each product's percentage of total revenue.

Validate the table/column names against your Gold-layer model before running.
*/

WITH product_metrics AS (
    SELECT
        p.product_key,
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        COUNT(DISTINCT f.order_number) AS order_count,
        SUM(f.quantity) AS units_sold
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY
        p.product_key,
        p.product_name
),
ranked_products AS (
    SELECT
        product_key,
        product_name,
        total_revenue,
        order_count,
        units_sold,
        RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
        100.0 * total_revenue
            / NULLIF(SUM(total_revenue) OVER (), 0) AS revenue_share_pct
    FROM product_metrics
)
SELECT
    revenue_rank,
    product_key,
    product_name,
    total_revenue,
    order_count,
    units_sold,
    CAST(revenue_share_pct AS DECIMAL(6, 2)) AS revenue_share_pct
FROM ranked_products
ORDER BY revenue_rank, product_name;
