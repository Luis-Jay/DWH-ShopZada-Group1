-- Load dim_staff from staging enterprise staff

INSERT INTO warehouse.dim_staff (staff_id, staff_name, role)
SELECT DISTINCT
    CAST(staff_id AS INTEGER) as staff_id,
    name as staff_name,
    job_level as role
FROM staging.staging_enterprise_staff
WHERE staff_id IS NOT NULL AND staff_id ~ '^[0-9]+$'  -- Only numeric IDs
ON CONFLICT (staff_id) DO UPDATE SET
    staff_name = EXCLUDED.staff_name,
    role = EXCLUDED.role,
    effective_date = CURRENT_TIMESTAMP,
    is_current = TRUE;

-- Log results
SELECT 'Dim staff loaded: ' || COUNT(*) || ' records' as message
FROM warehouse.dim_staff;
