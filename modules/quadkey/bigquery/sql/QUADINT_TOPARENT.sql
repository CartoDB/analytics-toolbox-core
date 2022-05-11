----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_TOPARENT`
(quadint INT64, resolution INT64)
RETURNS INT64
AS ((
    IF(resolution IS NULL OR resolution < 0 OR quadint IS NULL,
        ERROR('QUADINT_TOPARENT receiving wrong arguments')
        ,
        (
          WITH __parts AS (
            SELECT (quadint >> 5) AS xy, (quadint & 0x1F) AS z
          ),
          __zxy AS (
            SELECT
              z,
              xy & ((1 << z) - 1) AS x,
              xy >> z AS y
            FROM __parts
          ),
          __parent AS (
              SELECT
                resolution AS z,
                x >> (z - resolution) AS x,
                y >> (z - resolution) AS y
              FROM __zxy
          )
          SELECT (((y << z) | x) << 5) | z FROM __parent
        )
    )
));