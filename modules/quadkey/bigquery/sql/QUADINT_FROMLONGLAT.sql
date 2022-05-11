----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_FROMLONGLAT`
(longitude FLOAT64, latitude FLOAT64, resolution INT64)
RETURNS INT64
AS ((
  WITH __params AS (
  SELECT
    resolution AS z,
    ACOS(-1) AS PI
  ),
  __zxy AS (
    SELECT
      z,
      CAST(FLOOR((1 << z) * ((longitude / 360.0) + 0.5)) AS INT64) AS x,
      CAST(FLOOR((1 << z) * (0.5 - (LN(TAN(PI/4.0 + latitude/2.0 * PI/180.0)) / (2*PI)))) AS INT64) AS y
    FROM __params
  )
  SELECT (((y << z) | x) << 5) | z FROM __zxy
));