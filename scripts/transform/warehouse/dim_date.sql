-- Load dim_date with date range from 2020-01-01 to 2025-12-31

INSERT INTO warehouse.dim_date (
    full_date, year, quarter, month, month_name, week, day, day_of_week, day_name,
    is_weekend, is_holiday
)
SELECT
    full_date,
    EXTRACT(YEAR FROM full_date) as year,
    EXTRACT(QUARTER FROM full_date) as quarter,
    EXTRACT(MONTH FROM full_date) as month,
    TO_CHAR(full_date, 'Month') as month_name,
    EXTRACT(WEEK FROM full_date) as week,
    EXTRACT(DAY FROM full_date) as day,
    EXTRACT(DOW FROM full_date) as day_of_week,
    TO_CHAR(full_date, 'Day') as day_name,
    CASE WHEN EXTRACT(DOW FROM full_date) IN (0, 6) THEN TRUE ELSE FALSE END as is_weekend,
    FALSE as is_holiday  -- Placeholder for holiday logic
FROM generate_series(
    '2020-01-01'::date,
    '2025-12-31'::date,
    '1 day'::interval
) AS full_date
ON CONFLICT (full_date) DO NOTHING;

-- Log results
SELECT 'Dim date loaded: ' || COUNT(*) || ' records' as message
FROM warehouse.dim_date;
