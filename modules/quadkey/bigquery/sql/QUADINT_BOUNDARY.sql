----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_BOUNDARY`(quadint INT64)
RETURNS GEOGRAPHY
AS (
    CASE
      WHEN quadint IS NULL THEN
          ERROR('quadint argument cannot be NULL')
      -- Deal with level 0 boundary issue.
      WHEN quadint=0 THEN
          ST_GEOGFROMGEOJSON('{"coordinates":[[[-180,85.0511287798066],[-180,-85.0511287798066],[180,-85.0511287798066],[180,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}')
      -- Deal with level 1. Prevent error from antipodal vertices.
      WHEN quadint=1 THEN
          ST_GEOGFROMTEXT ("POLYGON((0 0, 0 85.0511287798066, -180 85.0511287798066, -180 0, -90 0, 0 0))")
      WHEN quadint=33 THEN
          ST_GEOGFROMTEXT ("POLYGON((180 0, 180 85.0511287798066, 0 85.0511287798066, 0 0, 90 0, 180 0))")
      WHEN quadint=65 THEN
          ST_GEOGFROMTEXT ("POLYGON((0 0, -90 0, 180 0, -180 -85.0511287798066, 0 -85.0511287798066, 0 0))")
      WHEN quadint=97 THEN
          ST_GEOGFROMTEXT ("POLYGON((180 0, 90 0, 0 0, 0 -85.0511287798066, 180 -85.0511287798066, 180 0))")
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
          ),
          __box AS (
            SELECT
              180 * (2.0 * x / CAST((1 << z) AS FLOAT64) - 1.0) AS minlon,
              360 * (ATAN(EXP(-(2.0 * (y + 1) / CAST((1 << z) AS FLOAT64) - 1) * PI)) / PI - 0.25) AS minlat,
              180 * (2.0 * (x + 1) / CAST((1 << z) AS FLOAT64) - 1.0) AS maxlon,
              360 * (ATAN(EXP(-(2.0 * y / CAST((1 << z) AS FLOAT64) - 1) * PI)) / PI - 0.25) AS maxlat
            FROM __zxy
          )
          SELECT
            ST_MAKEPOLYGON(
              ST_MAKELINE([
                  ST_GEOGPOINT(minlon, maxlat),
                  ST_GEOGPOINT(minlon, minlat),
                  ST_GEOGPOINT(maxlon, minlat),
                  ST_GEOGPOINT(maxlon, maxlat),
                  ST_GEOGPOINT(minlon, maxlat)
              ])
            )
            FROM __box
      )
    END
);