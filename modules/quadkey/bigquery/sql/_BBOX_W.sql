----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._BBOX_W`(quadint INT64)
RETURNS ARRAY<FLOAT64> AS (
`@@BQ_PREFIX@@quadkey._TILE2LAT`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
);