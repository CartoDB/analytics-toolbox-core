----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

-- Internal function: Uses VARCHAR for FLOAT8 to preserve precision
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__BEZIERSPLINE
(VARCHAR(MAX), INT, VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;
