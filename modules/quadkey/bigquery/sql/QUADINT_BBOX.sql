----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_BBOX`
(quadint INT64)
RETURNS ARRAY<FLOAT64>
AS ((
    WITH
    __check AS (
        SELECT COALESCE(quadint, ERROR('NULL argument passed to UDF')) AS quadint
    ),
    __parts AS (
        SELECT (quadint >> 5) AS xy, (quadint & 0x1F) AS z
        FROM __check
    ),
    __zxy AS (
        SELECT
          z,
          xy & ((1 << z) - 1) AS x,
          xy >> z AS y,
          ACOS(-1) AS PI
        FROM __parts
    )
    SELECT [
        180 * (2.0 * x / CAST((1 << z) AS FLOAT64) - 1.0),
        360 * (ATAN(EXP(-(2.0 * (y + 1) / CAST((1 << z) AS FLOAT64) - 1) * PI)) / PI - 0.25),
        180 * (2.0 * (x + 1) / CAST((1 << z) AS FLOAT64) - 1.0),
        360 * (ATAN(EXP(-(2.0 * y / CAST((1 << z) AS FLOAT64) - 1) * PI)) / PI - 0.25)
    ]
    FROM __zxy
));