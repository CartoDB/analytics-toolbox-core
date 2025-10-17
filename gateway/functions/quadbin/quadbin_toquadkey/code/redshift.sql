--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.QUADBIN_TOQUADKEY
(BIGINT)
-- (quadbin)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
