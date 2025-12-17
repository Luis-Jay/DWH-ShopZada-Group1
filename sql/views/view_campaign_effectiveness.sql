CREATE OR REPLACE VIEW presentation.view_campaign_effectiveness AS
SELECT
    c.campaign_name,
    COUNT(DISTINCT fcp.order_id) as total_orders,
    SUM(CASE WHEN fcp.availed THEN 1 ELSE 0 END) as campaigns_availed,
    ROUND(100.0 * SUM(CASE WHEN fcp.availed THEN 1 ELSE 0 END) / COUNT(*), 2) as avail_rate,
    SUM(fs.gross_amount) as total_revenue
FROM warehouse.fact_campaign_performance fcp
JOIN warehouse.dim_campaign c ON fcp.campaign_key = c.campaign_key
LEFT JOIN warehouse.fact_orders fs ON fcp.order_id = fs.order_id
WHERE c.is_current = true
GROUP BY c.campaign_name
ORDER BY total_revenue DESC;
