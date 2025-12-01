-- Presentation Schema DDL
-- Contains views and materialized views for BI and analytics

-- Create schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS presentation;

-- Grant permissions
GRANT USAGE ON SCHEMA presentation TO shopzada;
GRANT SELECT ON ALL TABLES IN SCHEMA presentation TO shopzada;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA presentation TO shopzada;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA presentation
GRANT SELECT ON TABLES TO shopzada;

ALTER DEFAULT PRIVILEGES IN SCHEMA presentation
GRANT SELECT ON SEQUENCES TO shopzada;

COMMENT ON SCHEMA presentation IS 'Presentation layer containing business intelligence views and aggregations';
