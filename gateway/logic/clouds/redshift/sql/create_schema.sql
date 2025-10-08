-- Create schema for CARTO Analytics Toolbox functions
-- Run this script to set up the schema in your Redshift database

-- Create the schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS carto;

-- Set search path to include the schema
SET search_path TO carto, public;

-- Grant usage on schema to appropriate users/roles
-- GRANT USAGE ON SCHEMA carto TO your_user_or_role;

-- Optional: Set default privileges for future objects
-- ALTER DEFAULT PRIVILEGES IN SCHEMA carto GRANT EXECUTE ON FUNCTIONS TO your_user_or_role;

-- Add comment
COMMENT ON SCHEMA carto IS 'CARTO Analytics Toolbox - Geospatial and analytical functions';
