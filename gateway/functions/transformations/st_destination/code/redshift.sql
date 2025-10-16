----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__DESTINATION
(geom VARCHAR(MAX), distance FLOAT8, bearing FLOAT8, units VARCHAR(15))
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
