/*
===============================================================================
Customer Order Gap Analysis
===============================================================================
Business question:
    How frequently do customers place orders, and how wide are the gaps
    between their purchases?

Grain:
    One row per customer.

Method:
    First aggregate fact_sales to one row per customer/order so multiple product
    lines in an order do not inflate order counts. Then use LAG to calculate
    elapsed calendar days between consecutive orders.

Expected columns in gold.fact_sales:
    customer_key, order_number, order_date, sales_amount

Notes:
    - Gap metrics exclude each customer's first order (there is no prior order).
    - Same-day separate orders have a zero-day gap.
    - This query is read-only and does not modify warehouse data.
===============================================================================
*/
WITH order_level AS (
    SELECT
        customer_key,
        order_number,
        MIN(order_date) AS order_date,
        SUM(sales_amount) AS order_revenue
    FROM gold.fact_sales
    WHERE customer_key IS NOT NULL
      AND order_number IS NOT NULL
      AND order_date IS NOT NULL
    GROUP BY
        customer_key,
        order_number
),
ordered_purchases AS (
    SELECT
        customer_key,
        order_number,
        order_date,
        order_revenue,
        LAG(order_date) OVER (
            PARTITION BY customer_key
            ORDER BY order_date, order_number
        ) AS previous_order_date
    FROM order_level
),
purchase_gaps AS (
    SELECT
        customer_key,
        order_number,
        order_date,
        order_revenue,
        previous_order_date,
        DATEDIFF(DAY, previous_order_date, order_date) AS days_since_previous_order
    FROM ordered_purchases
),
customer_summary AS (
    SELECT
        customer_key,
        COUNT(*) AS order_count,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        SUM(order_revenue) AS lifetime_revenue,
        COUNT(days_since_previous_order) AS repeat_order_intervals,
        AVG(CAST(days_since_previous_order AS DECIMAL(10, 2)))
            AS avg_days_between_orders,
        MIN(days_since_previous_order) AS shortest_gap_days,
        MAX(days_since_previous_order) AS longest_gap_days
    FROM purchase_gaps
    GROUP BY customer_key
)
SELECT
    customer_key,
    CASE
        WHEN order_count > 1 THEN 'Repeat Customer'
        ELSE 'One-time Customer'
    END AS purchase_type,
    order_count,
    first_order_date,
    last_order_date,
    lifetime_revenue,
    repeat_order_intervals,
    CAST(avg_days_between_orders AS DECIMAL(10, 2)) AS avg_days_between_orders,
    shortest_gap_days,
    longest_gap_days
FROM customer_summary
ORDER BY
    order_count DESC,
    lifetime_revenue DESC,
    customer_key;
