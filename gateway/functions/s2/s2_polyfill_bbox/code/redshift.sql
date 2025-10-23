--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

-- Internal functions: Use VARCHAR for FLOAT8 to preserve precision
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__S2_POLYFILL_BBOX_INTERNAL(
    VARCHAR(MAX),
    VARCHAR(MAX),
    VARCHAR(MAX),
    VARCHAR(MAX),
    INT4,
    INT4
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__S2_POLYFILL_BBOX_INTERNAL(
    VARCHAR(MAX),
    VARCHAR(MAX),
    VARCHAR(MAX),
    VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

-- Public functions: Convert FLOAT8 to VARCHAR and parse JSON result
CREATE OR REPLACE FUNCTION @@SCHEMA@@.S2_POLYFILL_BBOX(
    FLOAT8,
    FLOAT8,
    FLOAT8,
    FLOAT8,
    INT4,
    INT4
)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(
        @@SCHEMA@@.__S2_POLYFILL_BBOX_INTERNAL(
            CAST($1 AS VARCHAR(MAX)),
            CAST($2 AS VARCHAR(MAX)),
            CAST($3 AS VARCHAR(MAX)),
            CAST($4 AS VARCHAR(MAX)),
            $5,
            $6
        )
    )
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@SCHEMA@@.S2_POLYFILL_BBOX(
    FLOAT8,
    FLOAT8,
    FLOAT8,
    FLOAT8
)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(
        @@SCHEMA@@.__S2_POLYFILL_BBOX_INTERNAL(
            CAST($1 AS VARCHAR(MAX)),
            CAST($2 AS VARCHAR(MAX)),
            CAST($3 AS VARCHAR(MAX)),
            CAST($4 AS VARCHAR(MAX))
        )
    )
$$ LANGUAGE sql;
