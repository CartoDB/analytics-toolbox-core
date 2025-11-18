--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

-- Internal function: Uses VARCHAR for FLOAT8 inputs to preserve precision
-- (Redshift external functions lose FLOAT8 precision through JSON serialization)
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__QUADINT_FROMLONGLAT
(VARCHAR(MAX), VARCHAR(MAX), INT)
-- (longitude, latitude, resolution)
RETURNS BIGINT
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;

-- Public wrapper: Converts FLOAT8 to VARCHAR
CREATE OR REPLACE FUNCTION @@SCHEMA@@.QUADINT_FROMLONGLAT
(FLOAT8, FLOAT8, INT)
RETURNS BIGINT
STABLE
AS $$
    SELECT @@SCHEMA@@.__QUADINT_FROMLONGLAT(CAST($1 AS VARCHAR(MAX)), CAST($2 AS VARCHAR(MAX)), $3)
$$ LANGUAGE sql;
