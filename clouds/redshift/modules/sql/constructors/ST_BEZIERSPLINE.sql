----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__BEZIERSPLINE
(linestring VARCHAR(MAX), resolution INT, sharpness FLOAT8)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.constructors import bezier_spline

    if linestring is None or resolution is None or sharpness is None:
        return None

    return bezier_spline(linestring, resolution, sharpness)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_BEZIERSPLINE
(GEOMETRY)
-- (linestring)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMGEOJSON(@@RS_SCHEMA@@.__BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), 10000, 0.85))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_BEZIERSPLINE
(GEOMETRY, INT)
-- (linestring, resolution)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMGEOJSON(@@RS_SCHEMA@@.__BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, 0.85))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_BEZIERSPLINE
(GEOMETRY, INT, FLOAT8)
-- (linestring, resolution, sharpness)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMGEOJSON(@@RS_SCHEMA@@.__BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3))
$$ LANGUAGE sql;
