----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__GREATCIRCLE
(start_point VARCHAR(MAX), end_point VARCHAR(MAX), n_points INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import great_circle
    import geojson

    if start_point is None or end_point is None or n_points is None:
        return None

    return str(great_circle(geojson.loads(start_point), geojson.loads(end_point), n_points))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_GREATCIRCLE
(GEOMETRY, GEOMETRY)
-- (start_point, end_point, n_points)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@transformations.__GREATCIRCLE(ST_ASGEOJSON($1)::VARCHAR(MAX), ST_ASGEOJSON($2)::VARCHAR(MAX), 100))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_GREATCIRCLE
(GEOMETRY, GEOMETRY, INT)
-- (start_point, end_point, n_points)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@transformations.__GREATCIRCLE(ST_ASGEOJSON($1)::VARCHAR(MAX), ST_ASGEOJSON($2)::VARCHAR(MAX), $3))
$$ LANGUAGE sql;