----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey._TILE2LAT`(y FLOAT64,z FLOAT64)
RETURNS FLOAT64 AS (
COALESCE(
      180/ACOS(-1)*ATAN(0.5*(
      EXP(`@@BQ_PREFIX@@quadkey._N`(y,z))
      -EXP(-`@@BQ_PREFIX@@quadkey._N`(y,z))
      )),
ERROR('NULL argument passed to UDF')
)
);