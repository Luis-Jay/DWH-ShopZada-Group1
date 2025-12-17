-- Debug campaign staging data loading
-- Run these queries to see why campaigns aren't loading

-- 1. Check if staging table exists and has data
SELECT COUNT(*) as staging_campaigns_count FROM staging.staging_marketing_campaigns;

-- 2. Check raw data structure
SELECT * FROM staging.staging_marketing_campaigns LIMIT 10;

-- 3. Check campaign_id format
SELECT
    campaign_id,
    campaign_name,
    CASE
        WHEN campaign_id ~ 'CAMPAIGN\([0-9]+\)' THEN 'Matches pattern'
        ELSE 'Does not match'
    END as pattern_check,
    CASE
        WHEN campaign_id ~ 'CAMPAIGN\([0-9]+\)' THEN
            SUBSTRING(campaign_id FROM 'CAMPAIGN\(([0-9]+)\)')
        ELSE NULL
    END as extracted_id
FROM staging.staging_marketing_campaigns
LIMIT 10;

-- 4. Test the transformation logic manually
SELECT
    CAST(SUBSTRING(campaign_id FROM 'CAMPAIGN\(([0-9]+)\)') AS INTEGER) as campaign_id,
    campaign_name,
    campaign_description,
    discount
FROM staging.staging_marketing_campaigns
WHERE campaign_id IS NOT NULL
    AND campaign_id ~ 'CAMPAIGN\([0-9]+\)'
LIMIT 10;

-- 5. Check if warehouse schema exists
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'warehouse';

-- 6. Check if dim_campaign table exists
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'warehouse' AND table_name = 'dim_campaign';
