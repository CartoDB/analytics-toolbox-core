----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_BOUNDARY(
  quadbin BIGINT
)
RETURNS GEOMETRY
 AS
$BODY$
  WITH __bbox AS (
      SELECT @@PG_PREFIX@@carto.QUADBIN_BBOX(quadbin) AS b
  )
  SELECT ST_MakeEnvelope(b[1], b[2], b[3], b[4], 4326)
  FROM __bbox;
$BODY$
  LANGUAGE SQL;
