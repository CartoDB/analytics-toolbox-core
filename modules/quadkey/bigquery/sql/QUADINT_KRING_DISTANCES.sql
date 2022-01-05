----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__ZXY_KRING_DISTANCES`
  (origin STRUCT<z INT64, x INT64, y INT64>, size INT64)
AS ((
    SELECT
      ARRAY_AGG(STRUCT((`@@BQ_PREFIX@@carto.QUADINT_FROMZXY`(origin.z,
              IF(origin.x+dx<0,origin.x+dx+(1 << origin.z),origin.x+dx),
              origin.y+dy)) as index,
              greatest(abs(dx), abs(dy)) as distance -- Chebychev distance
              ))
    FROM
      UNNEST(GENERATE_ARRAY(-size,size)) dx,
      UNNEST(GENERATE_ARRAY(-size,size)) dy
    WHERE origin.y+dy >= 0 and origin.y+dy < (1 << origin.z)
));

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_KRING_DISTANCES`
(origin INT64, size INT64)
AS (
    `@@BQ_PREFIX@@carto.__ZXY_KRING_DISTANCES`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(
      IFNULL(IF(origin > 0, origin, NULL), Error('Invalid input origin'))),
      IFNULL(IF(size > 0, size, NULL), Error('Invalid input size'))));

