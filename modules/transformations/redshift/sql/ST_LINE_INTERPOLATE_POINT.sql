----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__LINE_INTERPOLATE_POINT
(geog VARCHAR(MAX), distance FLOAT8, units VARCHAR(15))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import along
    import geojson

    if geog is None:
        return None

    return str(along(geojson.loads(geog), distance, units))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_LINE_INTERPOLATE_POINT
(GEOMETRY, FLOAT8, VARCHAR(15))
-- (geog, distance, units)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__LINE_INTERPOLATE_POINT(ST_ASGEOJSON($1)::VARCHAR(MAX), $2, $3)
$$ LANGUAGE sql;