--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.QUADINT_TOQUADKEY
(BIGINT)
-- (quadint)
RETURNS VARCHAR
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;
