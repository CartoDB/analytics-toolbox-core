--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.QUADINT_BOUNDARY
(BIGINT)
-- (quadint)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
