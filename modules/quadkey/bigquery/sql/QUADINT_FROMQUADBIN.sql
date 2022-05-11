----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_FROMQUADBIN`
(quadbin INT64)
RETURNS INT64
AS ((
  WITH __zxy AS (
    SELECT `@@BQ_PREFIX@@carto.QUADBIN_TOZXY`(quadbin) AS zxy
  )
  SELECT (zxy.z & 0x1F) | (zxy.x << 5) | (zxy.y << (zxy.z + 5)) -- QUADINT_FROMZXY(zxy.z, zxy.x, zxy.y)
  FROM __zxy
));