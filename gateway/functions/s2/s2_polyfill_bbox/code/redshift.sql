--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__S2_POLYFILL_BBOX(
    min_longitude FLOAT8,
    max_longitude FLOAT8,
    min_latitude FLOAT8,
    max_latitude FLOAT8,
    min_resolution INT4,
    max_resolution INT4
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__S2_POLYFILL_BBOX(
    min_longitude FLOAT8,
    max_longitude FLOAT8,
    min_latitude FLOAT8,
    max_latitude FLOAT8
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

CREATE OR REPLACE FUNCTION @@SCHEMA@@.S2_POLYFILL_BBOX(
    min_longitude FLOAT8,
    max_longitude FLOAT8,
    min_latitude FLOAT8,
    max_latitude FLOAT8,
    min_resolution INT4,
    max_resolution INT4
)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@SCHEMA@@.__S2_POLYFILL_BBOX($1, $2, $3, $4, $5, $6))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@SCHEMA@@.S2_POLYFILL_BBOX(
    min_longitude FLOAT8,
    max_longitude FLOAT8,
    min_latitude FLOAT8,
    max_latitude FLOAT8
)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@SCHEMA@@.__S2_POLYFILL_BBOX($1, $2, $3, $4))
$$ LANGUAGE sql;
