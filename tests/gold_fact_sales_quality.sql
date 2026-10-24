/*
===============================================================================
Purpose: Read-only data-quality checks for gold.fact_sales.
Output: One row per check with affected-record count, severity, and result.
Run after the Gold fact table/view has been created.
Negative sales and nonpositive quantities are flagged for review because
returns or adjustments may be legitimate under the business rules.
===============================================================================
*/
WITH quality_counts AS (
    SELECT
        COUNT_BIG(*) AS total_rows,
        SUM(CASE WHEN order_number IS NULL THEN 1 ELSE 0 END) AS missing_order_number,
        SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
        SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
        SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS nonpositive_quantity,
        SUM(CASE WHEN sales_amount IS NULL THEN 1 ELSE 0 END) AS missing_sales_amount,
        SUM(CASE WHEN sales_amount < 0 THEN 1 ELSE 0 END) AS negative_sales_amount
    FROM gold.fact_sales
),
checks AS (
    SELECT 'Missing order number' AS check_name,
           COALESCE(missing_order_number, 0) AS issue_count,
           'HIGH' AS severity
    FROM quality_counts
    UNION ALL
    SELECT 'Missing order date', COALESCE(missing_order_date, 0), 'HIGH'
    FROM quality_counts
    UNION ALL
    SELECT 'Missing quantity', COALESCE(missing_quantity, 0), 'HIGH'
    FROM quality_counts
    UNION ALL
    SELECT 'Nonpositive quantity (review)',
           COALESCE(nonpositive_quantity, 0), 'MEDIUM'
    FROM quality_counts
    UNION ALL
    SELECT 'Missing sales amount', COALESCE(missing_sales_amount, 0), 'HIGH'
    FROM quality_counts
    UNION ALL
    SELECT 'Negative sales amount (review)',
           COALESCE(negative_sales_amount, 0), 'MEDIUM'
    FROM quality_counts
)
SELECT
    check_name,
    issue_count,
    severity,
    CASE WHEN issue_count = 0 THEN 'PASS' ELSE 'REVIEW' END AS result
FROM checks
ORDER BY
    CASE severity WHEN 'HIGH' THEN 1 ELSE 2 END,
    check_name;
