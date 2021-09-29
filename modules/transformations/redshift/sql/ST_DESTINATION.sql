----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__DESTINATION
(geog VARCHAR(MAX), distance FLOAT8, bearing FLOAT8, units VARCHAR(15))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import destination
    import geojson

    if geog is None or distance is None or bearing is None or units is None:
        return None

    return str(destination(geojson.loads(geog), distance, bearing, units))
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_DESTINATION
(GEOMETRY, FLOAT8, FLOAT8)
-- (geog, distance, bearing)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@transformations.__DESTINATION(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, 'kilometers'))
$$ LANGUAGE sql;


CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_DESTINATION
(GEOMETRY, FLOAT8, FLOAT8, VARCHAR(15))
-- (geog, distance, bearing, units)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@transformations.__DESTINATION(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4))
$$ LANGUAGE sql;