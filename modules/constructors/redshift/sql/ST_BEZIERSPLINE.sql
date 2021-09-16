----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors._BEZIERSPLINE
(geog VARCHAR(MAX), resolution INT, sharpness FLOAT8)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@constructorsLib import bezier_spline
    import geojson

    if geog is None or resolution is None or sharpness is None:
        return None

    result_geojson = bezier_spline(geojson.loads(geog), resolution, sharpness)
    return str(result_geojson['geometry'])
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_BEZIERSPLINE
(GEOMETRY)
-- (geog)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@constructors._BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), 10000, 0.85)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@constructors._BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), 10000, 0.85))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_BEZIERSPLINE
(GEOMETRY, INT)
-- (geog, resolution)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@constructors._BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, 0.85)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@constructors._BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, 0.85))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@constructors.ST_BEZIERSPLINE
(GEOMETRY, INT, FLOAT8)
-- (geog, resolution, sharpness)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@constructors._BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@constructors._BEZIERSPLINE(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3))
$$ LANGUAGE sql;