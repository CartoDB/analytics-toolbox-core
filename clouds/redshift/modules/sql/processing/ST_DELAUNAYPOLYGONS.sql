----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_DELAUNAYPOLYGONS
(GEOMETRY)
-- (points)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    SELECT @@RS_SCHEMA@@.__DELAUNAYGENERIC(ST_ASGEOJSON($1)::VARCHAR(MAX), 'poly')
$$ LANGUAGE sql;
