/*
===============================================================================
Category Repeat-Purchase Analysis
===============================================================================
Business question:
    Which product categories have the strongest repeat-purchase behavior?

Definitions:
    - A category customer is a distinct customer with at least one order in it.
    - A repeat customer has purchases in at least two distinct orders containing
      that category. Multiple product rows in the same order count once.
    - Repeat-purchase rate = repeat category customers / category customers.
    - Average revenue per customer is category revenue divided by category
      customers; customers may appear in more than one category.

Data source:
    gold.fact_sales joined to gold.dim_products.
===============================================================================
*/
WITH customer_category_purchases AS (
    SELECT
        p.category,
        f.customer_key,
        COUNT(DISTINCT f.order_number) AS distinct_orders,
        SUM(CAST(f.sales_amount AS DECIMAL(18, 2))) AS category_revenue
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    WHERE f.customer_key IS NOT NULL
      AND f.order_number IS NOT NULL
      AND p.category IS NOT NULL
    GROUP BY
        p.category,
        f.customer_key
),
category_summary AS (
    SELECT
        category,
        COUNT(*) AS customer_count,
        SUM(
            CASE WHEN distinct_orders >= 2 THEN 1 ELSE 0 END
        ) AS repeat_customer_count,
        SUM(category_revenue) AS total_revenue,
        AVG(category_revenue) AS average_revenue_per_customer,
        AVG(CAST(distinct_orders AS DECIMAL(10, 2)))
            AS average_orders_per_customer
    FROM customer_category_purchases
    GROUP BY category
)
SELECT
    category,
    customer_count,
    repeat_customer_count,
    CAST(
        100.0 * repeat_customer_count / NULLIF(customer_count, 0)
        AS DECIMAL(5, 2)
    ) AS repeat_purchase_rate_pct,
    CAST(total_revenue AS DECIMAL(18, 2)) AS total_revenue,
    CAST(
        average_revenue_per_customer AS DECIMAL(18, 2)
    ) AS average_revenue_per_customer,
    CAST(
        average_orders_per_customer AS DECIMAL(10, 2)
    ) AS average_orders_per_customer
FROM category_summary
ORDER BY
    repeat_purchase_rate_pct DESC,
    total_revenue DESC;
