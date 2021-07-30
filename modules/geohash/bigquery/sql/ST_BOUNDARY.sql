----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@geohash.ST_BOUNDARY`
(index STRING)
RETURNS GEOGRAPHY
AS ((
  WITH params_res AS (
    SELECT CHAR_LENGTH(index) AS resolution, CAST(FLOOR(5*(CHAR_LENGTH(index)-1)/2.0)+1 AS INT) AS power
  ),
  params_width AS (
    SELECT 90.0 / POWER(2, power) AS width FROM params_res
  ),
  params AS (
    SELECT
      width / 2 AS rx,
      IF(MOD(resolution, 2)=0, width/2, width) / 2 AS ry,
      SAFE.ST_GEOGPOINTFROMGEOHASH(index) AS center
    FROM params_res, params_width
  ),
  center_coords AS (
    SELECT ST_X(center) AS cx, ST_Y(center) AS cy
    FROM params
  )
  -- FIXME: for resolution > 17 the cell is too small and the points degenerate into a single one
  SELECT
    CASE WHEN cx IS NULL OR cy IS NULL THEN
        CAST(NULL AS GEOGRAPHY)
    ELSE
        ST_MAKEPOLYGONORIENTED([ST_MAKELINE([
            ST_GEOGPOINT(cx - rx, cy - ry),
            ST_GEOGPOINT(cx + rx, cy - ry),
            ST_GEOGPOINT(cx + rx, cy + ry),
            ST_GEOGPOINT(cx - rx, cy + ry),
            ST_GEOGPOINT(cx - rx, cy - ry)
        ])])
    END
    FROM params, center_coords
));
