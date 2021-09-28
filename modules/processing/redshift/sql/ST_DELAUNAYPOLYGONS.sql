----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.ST_DELAUNAYPOLYGONS
(GEOMETRY)
-- (points)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@processing.__DELAUNAYGENERIC(ST_ASGEOJSON($1)::VARCHAR(MAX), 'poly')
$$ LANGUAGE sql;