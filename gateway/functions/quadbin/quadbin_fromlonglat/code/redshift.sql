--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

-- Internal function: Uses VARCHAR inputs/outputs to preserve precision
-- (Redshift external functions lose precision for FLOAT8 and BIGINT through JSON serialization)
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__QUADBIN_FROMLONGLAT
(VARCHAR(MAX), VARCHAR(MAX), INT)
-- (longitude, latitude, resolution)
RETURNS BIGINT
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;

-- Public wrapper: Converts FLOAT8 to VARCHAR, then result to BIGINT
CREATE OR REPLACE FUNCTION @@SCHEMA@@.QUADBIN_FROMLONGLAT
(FLOAT8, FLOAT8, INT)
RETURNS BIGINT
STABLE
AS $$
    SELECT @@SCHEMA@@.__QUADBIN_FROMLONGLAT(CAST($1 AS VARCHAR(MAX)), CAST($2 AS VARCHAR(MAX)), $3)
$$ LANGUAGE sql;
