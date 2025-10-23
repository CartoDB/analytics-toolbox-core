--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__QUADINT_KRING
(BIGINT, INT)
-- (origin, size)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

CREATE OR REPLACE FUNCTION @@SCHEMA@@.QUADINT_KRING
(BIGINT, INT)
-- (origin, size)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@SCHEMA@@.__QUADINT_KRING($1, $2))
$$ LANGUAGE sql;
