----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__DESTINATION
(geom VARCHAR(MAX), distance FLOAT8, bearing FLOAT8, units VARCHAR(15))
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.transformations import destination, PRECISION, wkt_from_geojson
    import geojson
    import json

    if geom is None or distance is None or bearing is None or units is None:
        return None

    _geom = json.loads(geom)
    _geom['precision'] = PRECISION
    geojson_geom = json.dumps(_geom)
    geojson_geom = geojson.loads(geojson_geom)
    geojson_str = str(destination(geojson_geom, distance, bearing, units))
    
    return wkt_from_geojson(geojson_str)

$$ LANGUAGE PLPYTHONU;


CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_DESTINATION
(GEOMETRY, FLOAT8, FLOAT8)
-- (geom, distance, bearing)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__DESTINATION(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, 'kilometers'))
$$ LANGUAGE SQL;


CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_DESTINATION
(GEOMETRY, FLOAT8, FLOAT8, VARCHAR(15))
-- (geom, distance, bearing, units)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__DESTINATION(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3, $4))
$$ LANGUAGE SQL;
