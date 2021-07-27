----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._N`(y FLOAT64,z FLOAT64)
RETURNS FLOAT64 AS (
ACOS(-1)*(1-2*y/POW(2,z))
);