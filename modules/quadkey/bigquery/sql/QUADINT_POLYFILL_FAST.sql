----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

-- Experimental alternative POLYFILL
-- results are no exactly as previous QUADINT_POLYFILL
-- in that now not all cells intersecting the polygon are guaranteed
-- to be including, only those completely inside the polygon.
-- Results should't vary much, though, specially when cell size is much
-- smaller than the polygon.
-- The algorithm used is potentially faster; no intersection is computed for
-- every cell, but ST_MAKELINE and ST_INTERSECTION are computed for every
-- row of cells intersecting the polygon bounding box.
CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_POLYFILL_FAST`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
  WITH
  bbox AS (
    SELECT
      ST_BOUNDINGBOX(geog) AS box
  ),
  params AS (
    SELECT
      resolution AS z,
      box.xmin AS minlon, box.ymin AS minlat,
      box.xmax AS maxlon, box.ymax AS maxlat
    FROM bbox
  ),
  tile_coords_range AS (
    SELECT
      minlon, minlat, maxlon, maxlat,
      z,
      CAST(FLOOR((1 << z) * ((minlon / 360.0) + 0.5)) AS INT64) AS xmin,
      CAST(FLOOR((1 << z) * (0.5 - (LN(TAN(ACOS(-1)/4.0 + maxlat/2.0 * ACOS(-1)/180.0)) / (2*ACOS(-1))))) AS INT64) AS ymin,
      CAST(FLOOR((1 << z) * ((maxlon / 360.0) + 0.5)) AS INT64) AS xmax,
      CAST(FLOOR((1 << z) * (0.5 - (LN(TAN(ACOS(-1)/4.0 + minlat/2.0 * ACOS(-1)/180.0)) / (2*ACOS(-1))))) AS INT64) AS ymax
    FROM params
  ),
  cell_rows AS (
      SELECT
        z, xmin, xmax, minlon, maxlon, y
      FROM tile_coords_range, UNNEST(GENERATE_ARRAY(ymin, ymax)) AS y
  ),
   __rowcenters AS (
      SELECT
       z,minlon,maxlon,y,
       360 * (ATAN(EXP(-(2.0 * (y+0.5) / CAST((1 << z) AS FLOAT64) - 1) * ACOS(-1))) / ACOS(-1) - 0.25) AS midlat
       FROM cell_rows
    ),
    __int AS (
       SELECT z, y,
         ST_DUMP(ST_INTERSECTION(
           ST_MAKELINE(ST_GEOGPOINT(minlon, midlat), ST_GEOGPOINT(maxlon, midlat)),
           geog
         )) AS segments
       FROM __rowcenters
    ),
    __sections AS (
      SELECT z, y, ST_STARTPOINT(s) start_point, ST_ENDPOINT(s) end_point
      FROM __int, UNNEST(segments) AS s
    ),
    __cellranges AS (
        SELECT z, y,
        CAST(FLOOR((1 << z) * ((ST_X(start_point) / 360.0) + 0.5)) AS INT64) AS xstart,
        CAST(FLOOR((1 << z) * ((ST_X(end_point) / 360.0) + 0.5)) AS INT64) AS xend
      FROM __sections
    ),
    __cells AS (
      SELECT z, xs AS x, y FROM
      __cellranges, UNNEST(GENERATE_ARRAY(xstart, xend)) AS xs
    )
  SELECT
     ARRAY_AGG((((y << z) | x) << 5) | z)
  FROM __cells
));