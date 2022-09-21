----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_BOUNDARY(
    quadbin BIGINT
)
RETURNS GEOMETRY
AS
$BODY$
  WITH __bbox AS (
      SELECT @@PG_SCHEMA@@.QUADBIN_BBOX(quadbin) AS b
  )
  SELECT ST_MAKEENVELOPE(b[1], b[2], b[3], b[4], 4326)
  FROM __bbox;
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
