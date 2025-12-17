-- Debug script to check why view_campaign_effectiveness is empty
-- Run these queries ONE BY ONE in pgAdmin

-- 1. Check if fact_campaign_performance has data
SELECT COUNT(*) as campaign_fact_count FROM warehouse.fact_campaign_performance;

-- 2. Check if dim_campaign has data
SELECT COUNT(*) as campaign_dim_count FROM warehouse.dim_campaign;

-- 3. Check if fact_orders has data
SELECT COUNT(*) as orders_fact_count FROM warehouse.fact_orders;

-- 4. Check staging campaigns data
SELECT COUNT(*) as campaigns_count FROM staging.staging_marketing_campaigns;

-- 5. Check staging transactions data
SELECT COUNT(*) as transactions_count FROM staging.staging_marketing_transactions;

-- 6. Check sample data from fact_campaign_performance
SELECT * FROM warehouse.fact_campaign_performance LIMIT 5;

-- 7. Check sample data from dim_campaign
SELECT * FROM warehouse.dim_campaign LIMIT 5;

-- 8. Check order_id samples from campaign_performance
SELECT order_id, COUNT(*) as occurrences
FROM warehouse.fact_campaign_performance
GROUP BY order_id
ORDER BY occurrences DESC
LIMIT 10;

-- 9. Check order_id samples from fact_orders
SELECT order_id, COUNT(*) as occurrences
FROM warehouse.fact_orders
GROUP BY order_id
ORDER BY occurrences DESC
LIMIT 10;

-- 10. Test the campaign view join manually
SELECT
    c.campaign_name,
    COUNT(DISTINCT fcp.order_id) as total_orders,
    SUM(CASE WHEN fcp.availed THEN 1 ELSE 0 END) as campaigns_availed,
    COUNT(*) as total_records
FROM warehouse.fact_campaign_performance fcp
JOIN warehouse.dim_campaign c ON fcp.campaign_key = c.campaign_key
WHERE c.is_current = true
GROUP BY c.campaign_name;

-- 11. Test the full view
SELECT * FROM presentation.view_campaign_effectiveness LIMIT 10;
