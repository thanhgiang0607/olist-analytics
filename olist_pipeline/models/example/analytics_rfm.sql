{{ config(materialized='table') }}

-- Customer-level RFM on delivered orders (previously built in analytics.ipynb).
-- R/M scores are quintiles; F is bucketed by hand since most customers order once.
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        m.order_id,
        m.purchase_at,
        m.total_amount_paid
    FROM {{ ref('marts') }} m
    JOIN read_csv_auto({{ raw_path('olist_customers_dataset.csv') }}) c
        ON m.customer_id = c.customer_id
    WHERE m.order_status = 'delivered'
),

rfm_base AS (
    SELECT
        customer_unique_id,
        DATE_DIFF('day', MAX(purchase_at), (SELECT MAX(purchase_at) FROM customer_orders)) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(total_amount_paid) AS monetary
    FROM customer_orders
    GROUP BY customer_unique_id
),

scored AS (
    SELECT
        *,
        6 - NTILE(5) OVER (ORDER BY recency) AS R_score,
        NTILE(5) OVER (ORDER BY monetary) AS M_score,
        CASE WHEN frequency = 1 THEN 1 WHEN frequency = 2 THEN 2 ELSE 3 END AS F_score
    FROM rfm_base
)

SELECT
    *,
    CAST(R_score AS VARCHAR) || CAST(F_score AS VARCHAR) || CAST(M_score AS VARCHAR) AS RFM_Score,
    CASE
        WHEN R_score >= 4 AND F_score >= 2 THEN 'Champions / VIP'
        WHEN R_score >= 3 AND F_score >= 2 THEN 'Loyal Customers'
        WHEN R_score >= 4 AND F_score = 1  THEN 'Recent / New Customers'
        WHEN R_score = 3  AND F_score = 1  THEN 'Promising Customers'
        WHEN R_score = 2  AND F_score = 1  THEN 'Customers At Risk'
        WHEN R_score = 1  AND F_score >= 2 THEN 'Can''t Lose Them'
        ELSE 'Hibernating / Lost'
    END AS Segment
FROM scored
