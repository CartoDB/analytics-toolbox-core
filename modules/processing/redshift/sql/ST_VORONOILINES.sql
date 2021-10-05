----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.ST_VORONOILINES
(GEOMETRY, SUPER)
-- (points)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@processing.__VORONOIGENERIC(ST_ASGEOJSON($1)::VARCHAR(MAX), JSON_SERIALIZE($2)::VARCHAR(MAX), 'lines')
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION @@RS_PREFIX@@processing.ST_VORONOILINES
(GEOMETRY)
-- (points)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@processing.__VORONOIGENERIC(ST_ASGEOJSON($1)::VARCHAR(MAX), NULL, 'lines')
$$ LANGUAGE sql;