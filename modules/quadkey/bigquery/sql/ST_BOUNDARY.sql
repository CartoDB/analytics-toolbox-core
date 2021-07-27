----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_BOUNDARY`(quadint INT64)
RETURNS GEOGRAPHY AS (
ST_MAKEPOLYGON(
ST_MAKELINE([
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[0],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[3]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[0],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[1]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[2],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[1]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[2],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[3]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[0],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[3]
)
])
)
);