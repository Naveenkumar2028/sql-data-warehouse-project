/*
===============================================================================
Monthly Customer Cohort Retention
===============================================================================
Business question:
    For each month customers first purchased, what percentage returned in each
    later month?

Definitions:
    - Cohort month: calendar month of a customer's first recorded purchase.
    - Activity month: calendar month with at least one purchase.
    - Month 0 is the cohort's first-purchase month.
    - Retention rate = active customers / original cohort size * 100.

Notes:
    - Uses the existing Gold views: gold.fact_sales.
    - Counts each customer once per activity month, even with multiple orders.
    - Months with zero active customers are omitted; they can be filled with a
      calendar table when building a complete Power BI retention heatmap.
===============================================================================
*/
WITH customer_month_activity AS (
    SELECT DISTINCT
        customer_key,
        DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS activity_month
    FROM gold.fact_sales
    WHERE customer_key IS NOT NULL
      AND order_date IS NOT NULL
),
customer_cohorts AS (
    SELECT
        customer_key,
        MIN(activity_month) AS cohort_month
    FROM customer_month_activity
    GROUP BY customer_key
),
cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(*) AS cohort_size
    FROM customer_cohorts
    GROUP BY cohort_month
),
activity_by_cohort AS (
    SELECT
        c.cohort_month,
        a.activity_month,
        DATEDIFF(MONTH, c.cohort_month, a.activity_month)
            AS months_since_first_purchase,
        COUNT(DISTINCT a.customer_key) AS active_customers
    FROM customer_month_activity AS a
    INNER JOIN customer_cohorts AS c
        ON c.customer_key = a.customer_key
    GROUP BY
        c.cohort_month,
        a.activity_month,
        DATEDIFF(MONTH, c.cohort_month, a.activity_month)
)
SELECT
    a.cohort_month,
    a.activity_month,
    a.months_since_first_purchase,
    s.cohort_size,
    a.active_customers,
    CAST(
        100.0 * a.active_customers / NULLIF(s.cohort_size, 0)
        AS DECIMAL(5, 2)
    ) AS retention_rate_pct
FROM activity_by_cohort AS a
INNER JOIN cohort_sizes AS s
    ON s.cohort_month = a.cohort_month
ORDER BY
    a.cohort_month,
    a.months_since_first_purchase;
