CREATE OR REPLACE VIEW presentation.view_merchant_performance AS
SELECT
    dm.merchant_name,
    COUNT(DISTINCT fs.order_id) as total_orders,
    COUNT(DISTINCT fs.customer_key) as unique_customers,
    SUM(fs.total_amount) as total_revenue,
    ROUND(AVG(fs.total_amount), 2) as avg_order_value,
    ROUND(SUM(fs.total_amount) / COUNT(DISTINCT fs.order_id), 2) as revenue_per_order,
    ROUND(100.0 * SUM(fs.total_amount) / SUM(SUM(fs.total_amount)) OVER (), 2) as revenue_share_percentage,
    COUNT(DISTINCT CASE WHEN fs.on_time_delivery THEN fs.order_id END) as on_time_deliveries,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN fs.on_time_delivery THEN fs.order_id END) / COUNT(DISTINCT fs.order_id), 2) as on_time_delivery_rate
FROM warehouse.fact_sales fs
JOIN warehouse.dim_merchant dm ON fs.merchant_key = dm.merchant_key
WHERE dm.is_current = true
GROUP BY dm.merchant_name
ORDER BY total_revenue DESC;

COMMENT ON VIEW presentation.view_merchant_performance IS 'Merchant performance analysis with revenue, orders, and delivery metrics';
