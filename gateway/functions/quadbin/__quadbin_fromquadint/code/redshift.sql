--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__QUADBIN_FROMQUADINT
(BIGINT)
-- (quadint)
RETURNS BIGINT
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;
