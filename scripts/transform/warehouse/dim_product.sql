INSERT INTO warehouse.dim_product (product_id, product_name, product_type, price)
SELECT
    product_id,
    product_name,
    product_type,
    price
FROM (
    SELECT DISTINCT
        CAST(SUBSTRING(product_id FROM 'PRODUCT([0-9]+)') AS INTEGER) as product_id,
        product_name,
        product_type,
        price,
        ROW_NUMBER() OVER (PARTITION BY CAST(SUBSTRING(product_id FROM 'PRODUCT([0-9]+)') AS INTEGER) ORDER BY product_id) as rn
    FROM staging.staging_business_products
    WHERE product_id IS NOT NULL
) deduped
WHERE rn = 1
ON CONFLICT (product_id) DO UPDATE SET
    product_name = EXCLUDED.product_name,
    product_type = EXCLUDED.product_type,
    price = EXCLUDED.price,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;

-- Log results
SELECT 'Dim product loaded: ' || COUNT(*) || ' records' as message
FROM warehouse.dim_product;
