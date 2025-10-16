----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__CENTERMEAN
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
