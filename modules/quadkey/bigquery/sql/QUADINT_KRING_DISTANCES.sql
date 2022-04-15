----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADINT_ZXY_KRING_DISTANCES`
  (origin STRUCT<z INT64, x INT64, y INT64>, size INT64)
AS ((
    WITH T AS (
      SELECT
        `@@BQ_PREFIX@@carto.QUADINT_FROMZXY`(origin.z,
              MOD(origin.x+dx, (1 << origin.z)) + IF(origin.x+dx<0,(1 << origin.z),0),
              origin.y+dy) myindex,
        greatest(abs(dx), abs(dy)) distance -- Chebychev distance
      FROM
        UNNEST(GENERATE_ARRAY(-size,size)) dx,
        UNNEST(GENERATE_ARRAY(-size,size)) dy
      WHERE origin.y+dy >= 0 and origin.y+dy < (1 << origin.z)
      ),
      T_AGG AS (
      SELECT
        myindex,
        MIN(distance) as distance
      FROM
        T
      GROUP BY
      myindex
      )
    SELECT ARRAY_AGG(STRUCT(myindex as index, distance))
    FROM T_AGG
));

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_KRING_DISTANCES`
(origin INT64, size INT64)
AS (
    `@@BQ_PREFIX@@carto.__QUADINT_ZXY_KRING_DISTANCES`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(
      IFNULL(IF(origin < 0, NULL, origin), Error('Invalid input origin'))),
      IFNULL(IF(size >= 0, size, NULL), Error('Invalid input size'))));

