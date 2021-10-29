----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@processing.ST_POLYGONIZE
(lines ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$
   SELECT ARRAY_AGG(ST_ASGEOJSON(ST_MAKEPOLYGON(TO_GEOGRAPHY(line.VALUE)))::STRING)
   FROM LATERAL FLATTEN(input => lines) AS line
$$;