----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.BBOX`(quadint INT64)
RETURNS GEOGRAPHY AS (
ST_MAKEPOLYGON(
ST_MAKELINE([
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey._tile2lon`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._tile2lat`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey._tile2lon`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._tile2lat`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey._tile2lon`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._tile2lat`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey._tile2lon`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+1,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._tile2lat`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey._tile2lon`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._tile2lat`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y  ,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
)
])
)
);