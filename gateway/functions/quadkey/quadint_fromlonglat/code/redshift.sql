--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.QUADINT_FROMLONGLAT
(FLOAT8, FLOAT8, INT)
-- (longitude, latitude, resolution)
RETURNS BIGINT
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
