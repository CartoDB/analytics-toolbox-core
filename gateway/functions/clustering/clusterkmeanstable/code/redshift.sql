----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__CLUSTERKMEANSTABLE(
    geom VARCHAR(MAX),
    number_of_clusters INTEGER
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';
