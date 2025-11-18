----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

-- Internal function: Uses VARCHAR for FLOAT8 to preserve precision
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__MAKEELLIPSE(
    VARCHAR(MAX),
    VARCHAR(MAX),
    VARCHAR(MAX),
    VARCHAR(MAX),
    VARCHAR(10),
    INT
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@'
MAX_BATCH_ROWS @@MAX_BATCH_ROWS@@;
