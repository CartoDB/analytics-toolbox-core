----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.@@BQ_VERSION_FUNCTION@@`
()
RETURNS STRING
AS (
    '@@BQ_PACKAGE_VERSION@@'
);