--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.S2_FROMLONGLAT(
    longitude FLOAT8,
    latitude FLOAT8,
    resolution INT4
)
RETURNS INT8
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
