----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_BOUNDARY`(quadint INT64)
RETURNS GEOGRAPHY AS (
COALESCE(
ST_MAKEPOLYGON(
ST_MAKELINE([
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(0)],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(3)]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(0)],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(1)]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(2)],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(1)]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(2)],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(3)]
),
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(0)],
`@@BQ_PREFIX@@quadkey.BBOX`(quadint)[OFFSET(3)]
)
])
),
ERROR('NULL argument passed to UDF')
)
);