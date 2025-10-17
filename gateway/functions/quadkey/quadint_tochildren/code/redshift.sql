--------------------------------
-- Copyright (C) 2025 CARTO
--------------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__QUADINT_TOCHILDREN
(BIGINT, INT)
-- (quadint, resolution)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

CREATE OR REPLACE FUNCTION @@SCHEMA@@.QUADINT_TOCHILDREN
(BIGINT, INT)
-- (quadint, resolution)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@SCHEMA@@.__QUADINT_TOCHILDREN($1, $2))
$$ LANGUAGE sql;