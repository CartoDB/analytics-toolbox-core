----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._BBOX_S`(quadint INT64)
RETURNS FLOAT64 AS (
`@@BQ_PREFIX@@quadkey._TILE2LON`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
);