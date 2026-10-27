/*
===============================================================================
Category Profitability Analysis
===============================================================================
Business question:
    Which product categories and subcategories contribute the most revenue
    and estimated gross profit?

Grain:
    One row per category and subcategory.

Assumptions:
    - gold.dim_products.cost is the unit product cost.
    - gold.fact_sales.quantity is the quantity sold on each sales row.
    - Only rows with known category, subcategory, sales amount, quantity, and
      product cost are included so missing costs do not understate cost totals.
    - Gross profit is estimated as sales_amount - (unit cost * quantity);
      validate the cost definition against the source business rules.

Read-only query; uses the Gold-layer views defined in scripts/gold/ddl_gold.sql.
===============================================================================
*/
WITH eligible_sales AS (
    SELECT
        COALESCE(p.category, 'Uncategorized') AS category,
        COALESCE(p.subcategory, 'Uncategorized') AS subcategory,
        f.order_number,
        f.sales_amount,
        f.quantity,
        p.cost AS unit_cost
    FROM gold.fact_sales AS f
    INNER JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    WHERE f.sales_amount IS NOT NULL
      AND f.quantity IS NOT NULL
      AND p.cost IS NOT NULL
),
category_metrics AS (
    SELECT
        category,
        subcategory,
        COUNT(DISTINCT order_number) AS order_count,
        SUM(quantity) AS units_sold,
        SUM(sales_amount) AS total_revenue,
        SUM(unit_cost * quantity) AS estimated_product_cost,
        SUM(sales_amount) - SUM(unit_cost * quantity) AS estimated_gross_profit
    FROM eligible_sales
    GROUP BY category, subcategory
),
scored_categories AS (
    SELECT
        category,
        subcategory,
        order_count,
        units_sold,
        total_revenue,
        estimated_product_cost,
        estimated_gross_profit,
        100.0 * estimated_gross_profit / NULLIF(total_revenue, 0)
            AS estimated_gross_margin_pct,
        100.0 * total_revenue / NULLIF(SUM(total_revenue) OVER (), 0)
            AS revenue_share_pct,
        DENSE_RANK() OVER (
            ORDER BY estimated_gross_profit DESC
        ) AS gross_profit_rank
    FROM category_metrics
)
SELECT
    gross_profit_rank,
    category,
    subcategory,
    order_count,
    units_sold,
    total_revenue,
    estimated_product_cost,
    estimated_gross_profit,
    CAST(estimated_gross_margin_pct AS DECIMAL(7, 2)) AS estimated_gross_margin_pct,
    CAST(revenue_share_pct AS DECIMAL(7, 2)) AS revenue_share_pct
FROM scored_categories
ORDER BY gross_profit_rank, category, subcategory;
