-- Build/refresh the fact_orders table that powers downstream analytics.
-- The script assumes the staging layer already contains cleansed enterprise
-- order data and that dimension tables hold the latest surrogate keys.

CREATE TABLE IF NOT EXISTS warehouse.fact_orders (
    order_id                VARCHAR(100) PRIMARY KEY,
    customer_key            INT REFERENCES warehouse.dim_customer(customer_key),
    product_key             INT REFERENCES warehouse.dim_product(product_key),
    merchant_key            INT REFERENCES warehouse.dim_merchant(merchant_key),
    staff_key               INT REFERENCES warehouse.dim_staff(staff_key),
    campaign_key            INT REFERENCES warehouse.dim_campaign(campaign_key),
    order_date_key          INT REFERENCES warehouse.dim_date(date_key),
    estimated_arrival_key   INT REFERENCES warehouse.dim_date(date_key),
    quantity                INT,
    unit_price              NUMERIC(12,2),
    gross_amount            NUMERIC(14,2),
    discount_amount         NUMERIC(14,2),
    net_amount              NUMERIC(14,2),
    availed                 BOOLEAN,
    delivery_status         VARCHAR(50),
    logistics_provider      VARCHAR(100),
    processing_time_hours   INT,
    on_time_delivery        BOOLEAN,
    updated_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

WITH source_orders AS (
    SELECT
        oh.order_id,
        oh.transaction_date AS order_date,
        oh.user_id AS customer_id,
        lip.product_id,
        eo.merchant_id,
        eo.staff_id,
        CAST(REGEXP_REPLACE(lipr.quantity, '[^0-9.]', '', 'g') AS INTEGER) AS quantity,
        lipr.price AS unit_price,   -- ✅ FIXED
        0 AS discount,
        mt.campaign_id,
        mt.availed::BOOLEAN AS availed,
        CASE
            WHEN oh.estimated_arrival ~ '^[0-9]+days$' THEN
                oh.transaction_date + (CAST(SUBSTRING(oh.estimated_arrival FROM '([0-9]+)days') AS INTEGER) || ' days')::INTERVAL
            WHEN oh.estimated_arrival ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
                CAST(oh.estimated_arrival AS DATE)
            ELSE NULL
        END AS estimated_arrival_date,
        dd.delay_in_days,
        CASE
            WHEN dd.delay_in_days IS NULL THEN 'Delivered'
            WHEN dd.delay_in_days = 0 THEN 'Delivered'
            WHEN dd.delay_in_days > 0 THEN 'Delayed'
            ELSE 'Unknown'
        END                                                 AS delivery_status,
        'Standard'                                          AS logistics_provider,
        CASE
            WHEN dd.delay_in_days IS NULL THEN 24
            WHEN dd.delay_in_days = 0 THEN 24
            ELSE 24 + (dd.delay_in_days * 24)
        END                                                 AS processing_time_hours
    FROM staging.staging_operations_order_headers          oh
    LEFT JOIN staging.staging_operations_line_items_products lip ON lip.order_id = oh.order_id
    LEFT JOIN staging.staging_operations_line_items_prices lipr ON lipr.order_id = oh.order_id
    LEFT JOIN staging.staging_enterprise_orders             eo ON eo.order_id = oh.order_id
    LEFT JOIN staging.staging_marketing_transactions        mt ON mt.order_id = oh.order_id
    LEFT JOIN staging.staging_operations_delivery_delays    dd ON dd.order_id = oh.order_id
),
resolved_keys AS (
    SELECT
        so.order_id,
        -- Aggregate quantities and amounts at order level
        SUM(COALESCE(so.quantity, 1)) AS total_quantity,
        AVG(COALESCE(so.unit_price, 0)) AS avg_unit_price,
        SUM(COALESCE(so.quantity, 1) * COALESCE(so.unit_price, 0)::NUMERIC(14,2)) AS gross_amount,
        SUM((COALESCE(so.quantity, 1) * COALESCE(so.unit_price, 0)::NUMERIC(14,2)) * COALESCE(so.discount, 0)::NUMERIC(6,4)) AS discount_amount,
        -- Aggregate boolean values appropriately
        BOOL_OR(so.availed) AS availed,
        MAX(so.delivery_status) AS delivery_status,
        MAX(so.logistics_provider) AS logistics_provider,
        MAX(so.processing_time_hours) AS processing_time_hours,
        MAX(dc.customer_key) AS customer_key,
        MAX(dp.product_key) AS product_key,
        MAX(dm.merchant_key) AS merchant_key,
        MAX(ds.staff_key) AS staff_key,
        MAX(camp.campaign_key) AS campaign_key,
        MAX(od.date_key) AS order_date_key,
        MAX(ea.date_key) AS estimated_arrival_key
    FROM source_orders so
    LEFT JOIN warehouse.dim_customer dc ON dc.customer_id = CAST(SUBSTRING(so.customer_id FROM 'USER([0-9]+)') AS INTEGER) AND dc.is_current
    LEFT JOIN warehouse.dim_product  dp ON dp.product_id = CAST(SUBSTRING(so.product_id FROM 'PRODUCT([0-9]+)') AS INTEGER) AND dp.is_current
    LEFT JOIN warehouse.dim_merchant dm ON dm.merchant_id = CAST(SUBSTRING(so.merchant_id FROM 'MERCHANT([0-9]+)') AS INTEGER) AND dm.is_current
    LEFT JOIN warehouse.dim_staff    ds ON ds.staff_id = CAST(SUBSTRING(so.staff_id FROM 'STAFF([0-9]+)') AS INTEGER) AND ds.is_current
    LEFT JOIN warehouse.dim_campaign camp ON camp.campaign_id = CAST(SUBSTRING(so.campaign_id FROM 'CAMPAIGN([0-9]+)') AS INTEGER) AND camp.is_current
    LEFT JOIN warehouse.dim_date od  ON od.full_date = so.order_date
    LEFT JOIN warehouse.dim_date ea  ON ea.full_date = so.estimated_arrival_date
    GROUP BY so.order_id
)
INSERT INTO warehouse.fact_orders (
    order_id,
    customer_key,
    product_key,
    merchant_key,
    staff_key,
    campaign_key,
    order_date_key,
    estimated_arrival_key,
    quantity,
    unit_price,
    gross_amount,
    discount_amount,
    net_amount,
    availed,
    delivery_status,
    logistics_provider,
    processing_time_hours,
    on_time_delivery,
    updated_at
)
SELECT
    rk.order_id,
    rk.customer_key,
    rk.product_key,
    rk.merchant_key,
    rk.staff_key,
    rk.campaign_key,
    rk.order_date_key,
    rk.estimated_arrival_key,
    COALESCE(rk.total_quantity, 1),
    COALESCE(rk.avg_unit_price, 0),
    rk.gross_amount,
    rk.discount_amount,
    rk.gross_amount - rk.discount_amount AS net_amount,
    rk.availed,
    rk.delivery_status,
    rk.logistics_provider,
    rk.processing_time_hours,
    CASE
        WHEN rk.processing_time_hours IS NULL THEN NULL
        WHEN rk.processing_time_hours <= 48 AND rk.delivery_status ILIKE 'delivered%' THEN TRUE
        ELSE FALSE
    END AS on_time_delivery,
    CURRENT_TIMESTAMP
FROM resolved_keys rk
WHERE rk.order_date_key IS NOT NULL
ON CONFLICT (order_id) DO UPDATE SET
    customer_key          = EXCLUDED.customer_key,
    product_key           = EXCLUDED.product_key,
    merchant_key          = EXCLUDED.merchant_key,
    staff_key             = EXCLUDED.staff_key,
    campaign_key          = EXCLUDED.campaign_key,
    order_date_key        = EXCLUDED.order_date_key,
    estimated_arrival_key = EXCLUDED.estimated_arrival_key,
    quantity              = EXCLUDED.quantity,
    unit_price            = EXCLUDED.unit_price,
    gross_amount          = EXCLUDED.gross_amount,
    discount_amount       = EXCLUDED.discount_amount,
    net_amount            = EXCLUDED.net_amount,
    availed               = EXCLUDED.availed,
    delivery_status       = EXCLUDED.delivery_status,
    logistics_provider    = EXCLUDED.logistics_provider,
    processing_time_hours = EXCLUDED.processing_time_hours,
    on_time_delivery      = EXCLUDED.on_time_delivery,
    updated_at            = CURRENT_TIMESTAMP;
