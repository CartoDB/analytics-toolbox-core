----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT`(quadint INT64)
RETURNS GEOGRAPHY AS (
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey._TILE2LON`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+0.5,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._TILE2LAT`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+0.5,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
)
);