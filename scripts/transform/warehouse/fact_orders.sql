-- Build/refresh the fact_orders table that powers downstream analytics.
-- The script assumes the staging layer already contains cleansed enterprise
-- order data and that dimension tables hold the latest surrogate keys.

CREATE TABLE IF NOT EXISTS warehouse.fact_orders (
    order_id                INT PRIMARY KEY,
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
        eo.order_id,
        COALESCE(eo.order_date, mt.transaction_date)        AS order_date,
        eo.customer_id,
        eo.product_id,
        eo.merchant_id,
        eo.staff_id,
        eo.quantity,
        eo.unit_price,
        eo.discount,
        COALESCE(eo.campaign_id, mt.campaign_id)            AS campaign_id,
        mt.availed,
        mt.estimated_arrival,
        ofl.delivery_status,
        ofl.logistics_provider,
        ofl.processing_time                                AS processing_time_hours
    FROM staging.enterprise_orders          eo
    LEFT JOIN staging.marketing_transactions mt  ON mt.order_id = eo.order_id
    LEFT JOIN staging.operations_fulfillment ofl ON ofl.order_id = eo.order_id
),
resolved_keys AS (
    SELECT
        so.order_id,
        so.quantity,
        so.unit_price,
        so.discount,
        so.availed,
        so.delivery_status,
        so.logistics_provider,
        so.processing_time_hours,
        dc.customer_key,
        dp.product_key,
        dm.merchant_key,
        ds.staff_key,
        camp.campaign_key,
        od.date_key AS order_date_key,
        ea.date_key AS estimated_arrival_key,
        COALESCE(so.quantity, 1) * COALESCE(so.unit_price, 0)::NUMERIC(14,2) AS gross_amount,
        (COALESCE(so.quantity, 1) * COALESCE(so.unit_price, 0)::NUMERIC(14,2)) * COALESCE(so.discount, 0)::NUMERIC(6,4) AS discount_amount
    FROM source_orders so
    LEFT JOIN warehouse.dim_customer dc ON dc.customer_id = so.customer_id AND dc.is_current
    LEFT JOIN warehouse.dim_product  dp ON dp.product_id = so.product_id AND dp.is_current
    LEFT JOIN warehouse.dim_merchant dm ON dm.merchant_id = so.merchant_id AND dm.is_current
    LEFT JOIN warehouse.dim_staff    ds ON ds.staff_id = so.staff_id AND ds.is_current
    LEFT JOIN warehouse.dim_campaign camp ON camp.campaign_id = so.campaign_id AND camp.is_current
    LEFT JOIN warehouse.dim_date od  ON od.full_date = so.order_date
    LEFT JOIN warehouse.dim_date ea  ON ea.full_date = so.estimated_arrival
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
    COALESCE(rk.quantity, 1),
    COALESCE(rk.unit_price, 0),
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

