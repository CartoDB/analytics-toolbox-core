----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.PLACEKEY_ISVALID(
    placekey VARCHAR(19)
)
RETURNS BOOLEAN
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
