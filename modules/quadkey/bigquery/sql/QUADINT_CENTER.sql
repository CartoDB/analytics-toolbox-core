----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_CENTER`(quadint INT64)
RETURNS GEOGRAPHY
AS (
    CASE
      WHEN quadint IS NULL THEN
          ERROR('quadint argument cannot be NULL')
      -- Deal with level 0 boundary issue.
      WHEN quadint=0 THEN
          ST_GEOGPOINT(0,0)
      -- Deal with level 1. Prevent error from antipodal vertices.
      WHEN quadint=1 THEN
          ST_GEOGPOINT(-90,45)
      WHEN quadint=33 THEN
          ST_GEOGPOINT(90,45)
      WHEN quadint=65 THEN
          ST_GEOGPOINT(-90,-45)
      WHEN quadint=97 THEN
          ST_GEOGPOINT(90,-45)
      ELSE (
        WITH __parts AS (
            SELECT (quadint >> 5) AS xy, (quadint & 0x1F) AS z
        ),
        __zxy AS (
            SELECT
                z,
                xy & ((1 << z) - 1) AS x,
                xy >> z AS y,
                ACOS(-1) AS PI
            FROM __parts
        )
        SELECT ST_GEOGPOINT(
            180 * (2.0 * (x + 0.5) / CAST((1 << z) AS FLOAT64) - 1.0),
            360 * (ATAN(EXP(-(2.0 * (y + 0.5) / CAST((1 << z) AS FLOAT64) - 1) * PI)) / PI - 0.25)
        )
        FROM __zxy
      )
    END
);