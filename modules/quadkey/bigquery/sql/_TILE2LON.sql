----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._TILE2LON`(x FLOAT64, z FLOAT64)
RETURNS FLOAT64 AS (
COALESCE(
(x)/POW(2,z)*360-180,
ERROR('NULL argument passed to UDF')
)
);