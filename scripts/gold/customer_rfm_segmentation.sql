/*
===============================================================================
Customer RFM Segmentation
===============================================================================
Purpose:
    Group purchasing customers using Recency, Frequency, and Monetary value.
    Recency is measured against the latest order date in the dataset so results
    remain reproducible when the query is rerun later.

Scoring:
    Each metric is ranked into five relative buckets. A score of 5 is best.
    Segment names are practical starting heuristics, not fixed business rules.

Expected Gold-layer columns:
    gold.fact_sales: customer_key, order_number, order_date, sales_amount
    gold.dim_customers: customer_key, customer_id, first_name, last_name, country
===============================================================================
*/
WITH analysis_anchor AS (
    SELECT MAX(order_date) AS analysis_date
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
),
customer_metrics AS (
    SELECT
        c.customer_key,
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.country,
        MAX(f.order_date) AS last_order_date,
        DATEDIFF(DAY, MAX(f.order_date), a.analysis_date) AS recency_days,
        COUNT(DISTINCT f.order_number) AS frequency_orders,
        SUM(f.sales_amount) AS monetary_revenue
    FROM gold.dim_customers AS c
    INNER JOIN gold.fact_sales AS f
        ON f.customer_key = c.customer_key
    CROSS JOIN analysis_anchor AS a
    WHERE f.order_date IS NOT NULL
    GROUP BY
        c.customer_key,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        a.analysis_date
),
scored_customers AS (
    SELECT
        customer_key,
        customer_id,
        customer_name,
        country,
        last_order_date,
        recency_days,
        frequency_orders,
        monetary_revenue,
        6 - NTILE(5) OVER (ORDER BY recency_days ASC) AS recency_score,
        6 - NTILE(5) OVER (ORDER BY frequency_orders DESC) AS frequency_score,
        6 - NTILE(5) OVER (ORDER BY monetary_revenue DESC) AS monetary_score
    FROM customer_metrics
)
SELECT
    customer_key,
    customer_id,
    customer_name,
    country,
    last_order_date,
    recency_days,
    frequency_orders,
    monetary_revenue,
    recency_score,
    frequency_score,
    monetary_score,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_code,
    recency_score + frequency_score + monetary_score AS rfm_total_score,
    CASE
        WHEN recency_score >= 4
         AND frequency_score >= 4
         AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 4 THEN 'Loyal Customers'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'Recent Customers'
        WHEN recency_score <= 2 AND frequency_score >= 3 THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'Hibernating'
        ELSE 'Needs Nurturing'
    END AS customer_segment
FROM scored_customers
ORDER BY rfm_total_score DESC, monetary_revenue DESC, customer_name;
