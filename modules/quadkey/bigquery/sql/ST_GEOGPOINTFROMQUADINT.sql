----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__N`(quadint INT64)
RETURNS FLOAT64 AS (
ACOS(-1)-2*ACOS(-1)*(`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).y+0.5)/POW(2,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)
);


CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT`(quadint INT64)
RETURNS GEOGRAPHY AS (
ST_GEOGPOINT((`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).x+0.5)/POW(2,`@@BQ_PREFIX@@quadkey.ZXY_FROMQUADINT`(quadint).z)*360-180,
      180/ACOS(-1)*ATAN(0.5*(
      EXP(`@@BQ_PREFIX@@quadkey.__N`(quadint))
      -EXP(-`@@BQ_PREFIX@@quadkey.__N`(quadint))
      )))
);