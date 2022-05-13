
----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_FROMLONGLAT_ZOOMRANGE`
(longitude FLOAT64, latitude FLOAT64, zoom_min INT64, zoom_max INT64, zoom_step INT64, resolution INT64)
RETURNS ARRAY<STRUCT<id INT64, z INT64, x INT64, y INT64>>
AS ((
  IF(longitude IS NULL OR latitude IS NULL, [], (
    WITH
    __ixys AS (
        SELECT zs AS i,
          CAST(FLOOR((1 << (zs + resolution)) * ((longitude / 360.0) + 0.5)) AS INT64) AS ix,
          CAST(FLOOR((1 << (zs + resolution)) * (0.5 - (LN(TAN(ACOS(-1)/4.0 + latitude/2.0 * ACOS(-1)/180.0)) / (2*ACOS(-1))))) AS INT64) AS iy
      FROM
        UNNEST(GENERATE_ARRAY(zoom_min, zoom_max, zoom_step)) AS zs
    )
    SELECT ARRAY_AGG(STRUCT(
          (((iy << (i+resolution)) | ix) << 5) | (i+resolution) AS id,
          i AS z,
          ix >> resolution AS x,
          iy >> resolution AS y
    ))
    FROM __ixys
  ))
));