----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__GENERATEPOINTS
(geom VARCHAR(MAX), npoints INT)
RETURNS VARCHAR(MAX)
VOLATILE
AS $$
    from @@RS_LIBRARY@@.random import generatepoints
    return generatepoints(geom, npoints)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_GENERATEPOINTS
(GEOMETRY, INT)
-- (geom, npoints)
RETURNS VARCHAR(MAX)
VOLATILE
AS $$
    SELECT @@RS_SCHEMA@@.__GENERATEPOINTS(ST_ASGEOJSON($1), $2)
$$ LANGUAGE sql;
