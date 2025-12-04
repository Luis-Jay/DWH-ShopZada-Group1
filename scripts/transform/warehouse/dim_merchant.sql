-- Load dim_merchant from staging enterprise merchants

INSERT INTO warehouse.dim_merchant (merchant_id, merchant_name)
SELECT DISTINCT
    merchant_id,
    name as merchant_name
FROM staging.staging_enterprise_merchants
WHERE merchant_id IS NOT NULL
ON CONFLICT (merchant_id) DO UPDATE SET
    merchant_name = EXCLUDED.merchant_name,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;

-- Log results
SELECT 'Dim merchant loaded: ' || COUNT(*) || ' records' as message
FROM warehouse.dim_merchant;
