----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@._H3_COVERINGCELLIDS`
(geog GEOGRAPHY, resolution INT64)
AS ((
  ARRAY (
    WITH
      T2 AS (
        SELECT `@@BQ_DATASET@@.__S2_CENTER`(s2_index) h3_lonlat
        FROM UNNEST(S2_COVERINGCELLIDS(geog,
              max_level => [3,5,6,8,9,10,12,13,14,16,17,18,20,21,23,24][SAFE_OFFSET(resolution)],
              min_level => [3,5,6,8,9,10,12,13,14,16,17,18,20,21,23,24][SAFE_OFFSET(resolution)],
              max_cells => 1000000)) s2_index
      ),
      T3 AS (
        SELECT `@@BQ_DATASET@@.H3_FROMLONGLAT`(h3_lonlat.lng, h3_lonlat.lat, resolution) h3_cell
        FROM T2
      )
      SELECT DISTINCT h3_cell
      FROM T3
      WHERE ST_INTERSECTS(`@@BQ_DATASET@@.H3_BOUNDARY`(h3_cell), geog)
      GROUP BY h3_cell
  )
));
