----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._N`(y INT64,z INT64)
RETURNS FLOAT64 AS (
ACOS(-1)-2*ACOS(-1)*(y+0.5)/POW(2,z)
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._tile2lon`(x INT64, z INT64)
RETURNS FLOAT64 AS (
(x)/POW(2,z)*360-180
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._tile2lat`(y INT64,z INT64)
RETURNS FLOAT64 AS (
      180/ACOS(-1)*ATAN(0.5*(
      EXP(`@@BQ_PREFIX@@quadkey._N`(y,z))
      -EXP(-`@@BQ_PREFIX@@quadkey._N`(y,z))
      ))
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT`(quadint INT64)
RETURNS GEOGRAPHY AS (
ST_GEOGPOINT(
`@@BQ_PREFIX@@quadkey._tile2lon`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+0.5,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z),
`@@BQ_PREFIX@@quadkey._tile2lat`(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+0.5,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
)
);