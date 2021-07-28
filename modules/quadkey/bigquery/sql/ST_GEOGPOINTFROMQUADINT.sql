----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT`(quadint INT64)
RETURNS GEOGRAPHY AS (
ST_GEOGPOINT(
-- x + 0.5 is the mean between the western (x) and eastern (x+1) limits of the cell.
`@@BQ_PREFIX@@quadkey._TILE2LON`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+0.5,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
-- y + 0.5 is the mean between the northern (y) and southern (y+1) limits of the cell.
`@@BQ_PREFIX@@quadkey._TILE2LAT`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+0.5,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
)
);
