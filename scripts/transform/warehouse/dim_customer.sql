INSERT INTO warehouse.dim_customer (customer_id, name, job_title, job_level)
SELECT DISTINCT
    user_id,
    name,
    job_title,
    job_level
FROM staging.customer_management
ON CONFLICT (customer_id) DO UPDATE SET
    name = EXCLUDED.name,
    job_title = EXCLUDED.job_title,
    job_level = EXCLUDED.job_level,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;