----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.QUADINT_TOGEOGPOINT`(quadint INT64)
RETURNS GEOGRAPHY AS (
ST_GEOGPOINT(
-- x + 0.5 is the mean between the western (x) and eastern (x+1) limits of the cell.
`@@BQ_PREFIX@@quadkey.__TILE_TOLONG`(`@@BQ_PREFIX@@quadkey.QUADINT_TOZXY`(quadint).x+0.5,`@@BQ_PREFIX@@quadkey.QUADINT_TOZXY`(quadint).z),
-- y + 0.5 is the mean between the northern (y) and southern (y+1) limits of the cell.
`@@BQ_PREFIX@@quadkey.__TILE_TOLAT`(`@@BQ_PREFIX@@quadkey.QUADINT_TOZXY`(quadint).y+0.5,`@@BQ_PREFIX@@quadkey.QUADINT_TOZXY`(quadint).z)
)
);
