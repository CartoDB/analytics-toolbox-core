----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.PLACEKEY_ASH3(
    placekey VARCHAR(19)
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
