INSERT INTO warehouse.dim_product (product_id, product_name, product_type, price)
SELECT DISTINCT
    product_id,
    product_name,
    product_type,
    price
FROM staging.business_products
ON CONFLICT (product_id) DO UPDATE SET
    product_name = EXCLUDED.product_name,
    product_type = EXCLUDED.product_type,
    price = EXCLUDED.price,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;