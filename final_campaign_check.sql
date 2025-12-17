-- Final comprehensive check of campaign data flow
-- Run this to identify exactly where campaign data is missing

-- 1. Check all staging tables for campaign data
SELECT '=== STAGING TABLES ===' as section;
SELECT 'staging_marketing_campaigns' as table_name, COUNT(*) as row_count FROM staging.staging_marketing_campaigns
UNION ALL
SELECT 'staging_marketing_transactions' as table_name, COUNT(*) as row_count FROM staging.staging_marketing_transactions
UNION ALL
SELECT 'staging_operations_order_headers' as table_name, COUNT(*) as row_count FROM staging.staging_operations_order_headers;

-- 2. Check warehouse dimension tables
SELECT '=== WAREHOUSE DIMENSIONS ===' as section;
SELECT 'dim_campaign' as table_name, COUNT(*) as row_count FROM warehouse.dim_campaign
UNION ALL
SELECT 'dim_customer' as table_name, COUNT(*) as row_count FROM warehouse.dim_customer
UNION ALL
SELECT 'dim_merchant' as table_name, COUNT(*) as row_count FROM warehouse.dim_merchant;

-- 3. Check fact tables
SELECT '=== FACT TABLES ===' as section;
SELECT 'fact_orders' as table_name, COUNT(*) as row_count FROM warehouse.fact_orders
UNION ALL
SELECT 'fact_campaign_performance' as table_name, COUNT(*) as row_count FROM warehouse.fact_campaign_performance;

-- 4. Check campaign data samples
SELECT '=== CAMPAIGN DATA SAMPLES ===' as section;

-- Sample from staging campaigns
SELECT 'Staging campaigns sample:' as info;
SELECT * FROM staging.staging_marketing_campaigns LIMIT 3;

-- Sample from staging transactions
SELECT 'Staging transactions sample:' as info;
SELECT * FROM staging.staging_marketing_transactions LIMIT 3;

-- Sample from dim_campaign
SELECT 'Dim campaign sample:' as info;
SELECT * FROM warehouse.dim_campaign LIMIT 3;

-- Sample from fact_orders with campaign data
SELECT 'Fact orders with campaigns:' as info;
SELECT order_id, campaign_key, campaign_id FROM (
    SELECT fo.order_id, fo.campaign_key, mt.campaign_id
    FROM warehouse.fact_orders fo
    LEFT JOIN staging.staging_marketing_transactions mt ON fo.order_id = mt.order_id
    WHERE fo.campaign_key IS NOT NULL
    LIMIT 5
) t;

-- 5. Test campaign effectiveness view components
SELECT '=== CAMPAIGN EFFECTIVENESS COMPONENTS ===' as section;

-- Check if the view components work
SELECT
    'Campaigns in dim_campaign' as check_type,
    COUNT(*) as count
FROM warehouse.dim_campaign
WHERE is_current = true
UNION ALL
SELECT
    'Orders with campaign references' as check_type,
    COUNT(*) as count
FROM warehouse.fact_orders
WHERE campaign_key IS NOT NULL
UNION ALL
SELECT
    'Campaign performance records' as check_type,
    COUNT(*) as count
FROM warehouse.fact_campaign_performance;

-- 6. Manual view recreation test
SELECT '=== MANUAL VIEW TEST ===' as section;

-- Test the join manually
SELECT
    c.campaign_name,
    COUNT(DISTINCT fcp.order_id) as total_orders,
    SUM(CASE WHEN fcp.availed THEN 1 ELSE 0 END) as campaigns_availed
FROM warehouse.fact_campaign_performance fcp
JOIN warehouse.dim_campaign c ON fcp.campaign_key = c.campaign_key
WHERE c.is_current = true
GROUP BY c.campaign_name
LIMIT 5;
