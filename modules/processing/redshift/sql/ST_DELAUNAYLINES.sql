----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.ST_DELAUNAYLINES
(GEOMETRY)
-- (points)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    SELECT @@RS_PREFIX@@processing.__DELAUNAYGENERIC(ST_ASGEOJSON($1)::VARCHAR(MAX), 'lines')
$$ LANGUAGE sql;