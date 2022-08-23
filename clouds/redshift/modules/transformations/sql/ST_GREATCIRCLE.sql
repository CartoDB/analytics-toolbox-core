----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__GREATCIRCLE
(start_point VARCHAR(MAX), end_point VARCHAR(MAX), n_points INT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.transformations import great_circle, PRECISION, wkt_from_geojson
    import geojson
    import json

    if start_point is None or end_point is None or n_points is None:
        return None

    _geom = json.loads(start_point)
    _geom['precision'] = PRECISION
    start_geom = json.dumps(_geom)
    start_geom = geojson.loads(start_geom)

    _geom = json.loads(end_point)
    _geom['precision'] = PRECISION
    end_geom = json.dumps(_geom)
    end_geom = geojson.loads(end_geom)
    geojson_str = str(great_circle(start_geom, end_geom, n_points))

    return wkt_from_geojson(geojson_str)

$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_GREATCIRCLE
(GEOMETRY, GEOMETRY)
-- (start_point, end_point, n_points)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__GREATCIRCLE(ST_ASGEOJSON($1)::VARCHAR(MAX), ST_ASGEOJSON($2)::VARCHAR(MAX), 100))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_GREATCIRCLE
(GEOMETRY, GEOMETRY, INT)
-- (start_point, end_point, n_points)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__GREATCIRCLE(ST_ASGEOJSON($1)::VARCHAR(MAX), ST_ASGEOJSON($2)::VARCHAR(MAX), $3))
$$ LANGUAGE sql;