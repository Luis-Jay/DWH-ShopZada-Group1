-- Load dim_campaign from staging marketing campaigns

INSERT INTO warehouse.dim_campaign (campaign_id, campaign_name, campaign_description, discount)
SELECT DISTINCT
    campaign_id,
    campaign_name,
    campaign_description,
    discount
FROM staging.staging_marketing_campaigns
WHERE campaign_id IS NOT NULL
ON CONFLICT (campaign_id) DO UPDATE SET
    campaign_name = EXCLUDED.campaign_name,
    campaign_description = EXCLUDED.campaign_description,
    discount = EXCLUDED.discount,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;

-- Log results
SELECT 'Dim campaign loaded: ' || COUNT(*) || ' records' as message
FROM warehouse.dim_campaign;
