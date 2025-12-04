-- Load dim_customer from staging tables
-- Combine profiles, jobs, and cards data

INSERT INTO warehouse.dim_customer (customer_id, name, job_title, job_level)
SELECT DISTINCT
    COALESCE(p.user_id, j.user_id, c.user_id) as customer_id,
    COALESCE(p.name, c.name, j.name) as name,
    COALESCE(j.job_title, '') as job_title,
    COALESCE(j.job_level, '') as job_level
FROM staging.staging_customer_profiles p
FULL OUTER JOIN staging.staging_customer_jobs j ON p.user_id = j.user_id
FULL OUTER JOIN staging.staging_customer_cards c ON COALESCE(p.user_id, j.user_id) = c.user_id
WHERE COALESCE(p.user_id, j.user_id, c.user_id) IS NOT NULL
ON CONFLICT (customer_id) DO UPDATE SET
    name = EXCLUDED.name,
    job_title = EXCLUDED.job_title,
    job_level = EXCLUDED.job_level,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;

-- Log results
SELECT 'Dim customer loaded: ' || COUNT(*) || ' records' as message
FROM warehouse.dim_customer;
