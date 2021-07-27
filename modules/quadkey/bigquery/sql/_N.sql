----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._N`(y FLOAT64,z FLOAT64)
RETURNS FLOAT64 AS (
ACOS(-1)-2*ACOS(-1)*(y+0.5)/POW(2,z)
);