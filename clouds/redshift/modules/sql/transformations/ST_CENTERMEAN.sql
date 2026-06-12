--------------------------------
-- Copyright (C) 2021-2025 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_CENTERMEAN
(GEOMETRY)
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$

    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__CENTERMEAN(ST_ASGEOJSON($1)::VARCHAR(MAX)), 4326)
    
$$ LANGUAGE sql;
