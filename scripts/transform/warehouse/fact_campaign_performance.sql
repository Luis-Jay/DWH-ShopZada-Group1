-- Refresh the fact_campaign_performance table
-- This table captures campaign performance metrics at the order level

-- Ensure table exists with correct schema
CREATE TABLE IF NOT EXISTS warehouse.fact_campaign_performance (
    campaign_perf_key SERIAL PRIMARY KEY,
    campaign_key INT REFERENCES warehouse.dim_campaign(campaign_key),
    order_id VARCHAR(100),  -- VARCHAR to match fact_orders
    transaction_date_key INT REFERENCES warehouse.dim_date(date_key),
    availed BOOLEAN,
    estimated_arrival DATE,
    conversion_flag BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Clear existing data (instead of dropping table to preserve dependencies)
TRUNCATE TABLE warehouse.fact_campaign_performance RESTART IDENTITY;

-- Insert campaign performance data from staging
INSERT INTO warehouse.fact_campaign_performance (
    campaign_key,
    order_id,
    transaction_date_key,
    availed,
    estimated_arrival,
    conversion_flag,
    created_at
)
SELECT
    dc.campaign_key,
    smt.order_id,
    dd.date_key,
    CASE WHEN smt.availed = 1 THEN TRUE ELSE FALSE END as availed,
    CASE
        WHEN smt.estimated_arrival ~ '^[0-9]+days$' THEN
            smt.transaction_date + (CAST(SUBSTRING(smt.estimated_arrival FROM '([0-9]+)days') AS INTEGER) || ' days')::INTERVAL
        WHEN smt.estimated_arrival ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
            CAST(smt.estimated_arrival AS DATE)
        ELSE NULL
    END AS estimated_arrival,
    CASE WHEN smt.availed = 1 THEN TRUE ELSE FALSE END as conversion_flag,
    CURRENT_TIMESTAMP
FROM staging.staging_marketing_transactions smt
LEFT JOIN warehouse.dim_campaign dc ON dc.campaign_id = CASE
    WHEN smt.campaign_id ~ '^CAMPAIGN[0-9]+$' THEN
        CAST(SUBSTRING(smt.campaign_id FROM 'CAMPAIGN([0-9]+)$') AS INTEGER)
    WHEN smt.campaign_id ~ '^CAMPAIGN\([0-9]+\)$' THEN
        CAST(SUBSTRING(smt.campaign_id FROM 'CAMPAIGN\(([0-9]+)\)') AS INTEGER)
    WHEN smt.campaign_id ~ '^CAMPAIGN\s*[0-9]+$' THEN
        CAST(SUBSTRING(smt.campaign_id FROM 'CAMPAIGN\s*([0-9]+)$') AS INTEGER)
    WHEN smt.campaign_id ~ '^[0-9]+$' THEN
        CAST(smt.campaign_id AS INTEGER)
    WHEN smt.campaign_id ~ '[0-9]+' THEN
        CAST((REGEXP_MATCH(smt.campaign_id, '([0-9]+)'))[1] AS INTEGER)
    ELSE NULL
END AND dc.is_current = true
LEFT JOIN warehouse.dim_date dd ON dd.full_date = smt.transaction_date
WHERE smt.order_id IS NOT NULL;

-- Create index for performance (only if they don't exist)
CREATE INDEX IF NOT EXISTS idx_fact_campaign_perf_order_id ON warehouse.fact_campaign_performance(order_id);
CREATE INDEX IF NOT EXISTS idx_fact_campaign_perf_date ON warehouse.fact_campaign_performance(transaction_date_key);
