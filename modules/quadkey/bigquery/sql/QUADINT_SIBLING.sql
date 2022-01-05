----------------------------
-- Copyright (C) 2021 CARTO
----------------------------


----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__ZXY_QUADINT_SIBLING`
  (origin STRUCT<z INT64, x INT64, y INT64>, dx INT64, dy INT64)
AS (
    IF(origin.y+dy >= 0 and origin.y+dy < (1 << origin.z),
      `@@BQ_PREFIX@@carto.QUADINT_FROMZXY`(origin.z,
              IF(origin.x+dx<0,origin.x+dx+(1 << origin.z),origin.x+dx),
              origin.y+dy),
              NULL
    )
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADINT_SIBLING`
(origin INT64, dx INT64, dy INT64)
AS (
    `@@BQ_PREFIX@@carto.__ZXY_QUADINT_SIBLING`(`@@BQ_PREFIX@@carto.QUADINT_TOZXY`(
      IFNULL(IF(origin > 0, origin, NULL), Error('NULL argument passed to UDF'))),
      IFNULL(dx, Error('Invalid input dx')),
      IFNULL(dy, Error('Invalid input dy'))));


CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_SIBLING`
(quadint INT64, direction STRING)
AS (
    IF(direction='left',`@@BQ_PREFIX@@carto.__QUADINT_SIBLING`(quadint,-1,0),
        IF(direction='right',`@@BQ_PREFIX@@carto.__QUADINT_SIBLING`(quadint,1,0),
            IF(direction='up',`@@BQ_PREFIX@@carto.__QUADINT_SIBLING`(quadint,0,-1),
                IF(direction='down',`@@BQ_PREFIX@@carto.__QUADINT_SIBLING`(quadint,0,1),
                    Error('Wrong direction argument passed to sibling')))))
);
