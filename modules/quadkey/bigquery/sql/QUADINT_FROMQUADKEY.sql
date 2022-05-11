----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_FROMQUADKEY`
(quadkey STRING)
RETURNS INT64
AS ((
    WITH
    __zdigits AS (
      SELECT
        CHAR_LENGTH(quadkey) & 0x1F AS z,
        SPLIT(quadkey,'') AS _digits
    ),
    __unnestcontainer AS (
      SELECT
        z,
        (
          SELECT AS STRUCT
            SUM( (CAST(_digit AS INT64) & 1) << (__zdigits.z - _pos - 1) ) AS x,
            SUM( ((CAST(_digit AS INT64) >> 1) & 1) << (__zdigits.z - _pos - 1) ) AS y
          FROM UNNEST(_digits) AS _digit WITH OFFSET AS _pos
        ) AS xy
      FROM __zdigits
    )
    SELECT (((xy.y << z) | xy.x) << 5) | z FROM __unnestcontainer
));