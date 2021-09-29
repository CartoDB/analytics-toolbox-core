----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__CENTROID
(geog VARCHAR(MAX), area_poly FLOAT8, length_line FLOAT8)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import centroid
    import geojson

    if geog is None:
        return None

    return str(centroid(geojson.loads(geog), area_poly, length_line))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_CENTROID
(GEOMETRY)
-- (geog)
RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__ST_GEOMFROMGEOJSON(@@RS_PREFIX@@transformations.__CENTROID(ST_ASGEOJSON($1)::VARCHAR(MAX), ST_AREA($1), ST_LENGTH($1)))
$$ LANGUAGE sql;