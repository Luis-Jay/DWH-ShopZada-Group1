-- Staging Layer Transformations
-- Basic validation and cleansing of raw data

-- Validate that key tables have data
DO $$
DECLARE
    customer_count INT;
    product_count INT;
    order_count INT;
BEGIN
    SELECT COUNT(*) INTO customer_count FROM staging.staging_customer_profiles;
    SELECT COUNT(*) INTO product_count FROM staging.staging_business_products;
    SELECT COUNT(*) INTO order_count FROM staging.staging_operations_order_headers;

    RAISE NOTICE 'Staging validation - Customers: %, Products: %, Orders: %',
        customer_count, product_count, order_count;

    -- Basic data quality checks
    IF customer_count = 0 OR product_count = 0 OR order_count = 0 THEN
        RAISE EXCEPTION 'Insufficient data in staging layer';
    END IF;
END $$;

-- Could add more transformations here like:
-- - Standardizing formats
-- - Deduplication
-- - Basic cleansing

SELECT 'Staging transformations completed successfully' as message;
