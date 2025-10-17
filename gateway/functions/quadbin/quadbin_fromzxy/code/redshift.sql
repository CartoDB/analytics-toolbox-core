--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.QUADBIN_FROMZXY
(BIGINT, BIGINT, BIGINT)
-- (z, x, y)
RETURNS BIGINT
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
