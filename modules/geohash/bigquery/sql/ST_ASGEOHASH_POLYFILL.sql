----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@geohash.ST_ASGEOHASH_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRING>
AS ((
  WITH bbox AS (
    SELECT `@@BQ_PREFIX@@random.__BBOX_FROM_GEOJSON`(ST_ASGEOJSON(geog)) AS bb
  ),
  limits AS (
    SELECT
      bb[ORDINAL(1)] AS xmin,
      bb[ORDINAL(2)] AS ymin,
      bb[ORDINAL(3)] AS xmax,
      bb[ORDINAL(4)] AS ymax
    FROM bbox
  ),
  params_power AS (
    SELECT CAST(FLOOR(5*(resolution-1)/2.0)+1 AS INT) AS power
  ),
  grid_cell AS (
    SELECT
      90.0 / POWER(2, power) AS xsize,
      IF(MOD(resolution, 2)=0, 90.0 / POWER(2, power + 1), 90.0 / POWER(2, power)) AS ysize
    FROM params_power
  ),
  grid_limits AS (
    SELECT
      FLOOR(xmin / xsize) AS istart,
      CEIL(xmax / xsize) AS iend,
      FLOOR(ymin / ysize) AS jstart,
      CEIL(ymax / ysize) AS jend
    FROM limits, grid_cell
  ),
  centers AS (
    SELECT
      ST_GEOGPOINT((i + 0.5) * xsize, (j + 0.5) * ysize) AS c
    FROM grid_limits, grid_cell, UNNEST(GENERATE_ARRAY(istart, iend)) AS i, UNNEST(GENERATE_ARRAY(jstart, jend)) AS j
  )
  SELECT ARRAY(
    SELECT
      ST_GEOHASH(c, resolution)
      FROM centers
      WHERE ST_WITHIN(c, geog) -- ST_INTERSECTS(geohash.ST_BOUNDARY(ST_GEOHASH(c, resolution)), geog)
  )
));
