----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.BBOX`(quadint INT64)
RETURNS ARRAY<FLOAT64> AS (
[
`@@BQ_PREFIX@@quadkey._TILE2LON`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._TILE2LAT`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._TILE2LON`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._TILE2LAT`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
]
);