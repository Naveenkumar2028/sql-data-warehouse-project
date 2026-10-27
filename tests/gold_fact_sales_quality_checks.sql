/*
===============================================================================
Gold Fact Sales - Data Quality Checks
===============================================================================
Purpose:
    Return a compact PASS/FAIL result for core fields used by the analytics
    queries in this repository.

Checks:
    - Required order date, customer key, order number, and sales amount.
    - Fact rows whose non-null customer key has no matching Gold customer.

Run after the Gold views/tables are available. This script is read-only.
A FAIL row reports the number of records that need investigation; it does not
modify or delete source data.
===============================================================================
*/
WITH quality_checks AS (
    SELECT
        'null_order_date' AS check_name,
        COUNT_BIG(*) AS failing_rows
    FROM gold.fact_sales
    WHERE order_date IS NULL

    UNION ALL

    SELECT
        'null_customer_key',
        COUNT_BIG(*)
    FROM gold.fact_sales
    WHERE customer_key IS NULL

    UNION ALL

    SELECT
        'null_order_number',
        COUNT_BIG(*)
    FROM gold.fact_sales
    WHERE order_number IS NULL

    UNION ALL

    SELECT
        'null_sales_amount',
        COUNT_BIG(*)
    FROM gold.fact_sales
    WHERE sales_amount IS NULL

    UNION ALL

    SELECT
        'orphan_customer_key',
        COUNT_BIG(*)
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
        ON c.customer_key = f.customer_key
    WHERE f.customer_key IS NOT NULL
      AND c.customer_key IS NULL
)
SELECT
    check_name,
    failing_rows,
    CASE
        WHEN failing_rows = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS check_status
FROM quality_checks
ORDER BY check_name;
