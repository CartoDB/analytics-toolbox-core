----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_TOCHILDREN`
(quadint INT64, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
  WITH __parts AS (
    SELECT (quadint >> 5) AS xy, (quadint & 0x1F) AS z
  ),
  __zxy AS (
    SELECT
      z,
      xy & ((1 << z) - 1) AS x,
      xy >> z AS Y,
      resolution - z AS d
    FROM __parts
  )
  SELECT
    ARRAY_AGG((((ys << (z+d)) | xs) << 5) | (z+d))
  FROM
    __zxy,
    UNNEST(GENERATE_ARRAY(x << d, ((x + 1) << d) - 1)) AS xs,
    UNNEST(GENERATE_ARRAY(y << d, ((y + 1) << d) - 1)) AS ys
));