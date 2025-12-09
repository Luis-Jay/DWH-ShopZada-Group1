-- Load dim_merchant from staging enterprise merchants

INSERT INTO warehouse.dim_merchant (merchant_id, merchant_name)
SELECT
    merchant_id,
    merchant_name
FROM (
    SELECT DISTINCT
        CAST(SUBSTRING(merchant_id FROM 'MERCHANT([0-9]+)') AS INTEGER) as merchant_id,
        name as merchant_name,
        ROW_NUMBER() OVER (PARTITION BY CAST(SUBSTRING(merchant_id FROM 'MERCHANT([0-9]+)') AS INTEGER) ORDER BY merchant_id) as rn
    FROM staging.staging_enterprise_merchants
    WHERE merchant_id IS NOT NULL
) deduped
WHERE rn = 1
ON CONFLICT (merchant_id) DO UPDATE SET
    merchant_name = EXCLUDED.merchant_name,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;

-- Log results
SELECT 'Dim merchant loaded: ' || COUNT(*) || ' records' as message
FROM warehouse.dim_merchant;
