----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__GREATCIRCLE
(start_point VARCHAR(MAX), end_point VARCHAR(MAX), n_points INT)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
