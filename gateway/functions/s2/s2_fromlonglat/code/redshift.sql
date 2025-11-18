--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

-- Internal function: Uses VARCHAR for FLOAT8 to preserve precision
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__S2_FROMLONGLAT(
    VARCHAR(MAX),
    VARCHAR(MAX),
    INT4
)
RETURNS INT8
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;

-- Public wrapper: Converts FLOAT8 to VARCHAR
CREATE OR REPLACE FUNCTION @@SCHEMA@@.S2_FROMLONGLAT(
    FLOAT8,
    FLOAT8,
    INT4
)
RETURNS INT8
STABLE
AS $$
    SELECT @@SCHEMA@@.__S2_FROMLONGLAT(
        CAST($1 AS VARCHAR(MAX)),
        CAST($2 AS VARCHAR(MAX)),
        $3
    )
$$ LANGUAGE sql;
