----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__MAKEELLIPSE(
    center VARCHAR(MAX),
    xSemiAxis FLOAT8,
    ySemiAxis FLOAT8,
    angle FLOAT8,
    units VARCHAR(10),
    steps INT
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
