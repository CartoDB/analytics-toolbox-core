----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__CENTERMEAN
(geog VARCHAR(MAX))
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import center_mean
    import geojson

    if geog is None:
        return None

    return center_mean(geojson.loads(geog))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_CENTERMEAN
(GEOMETRY)
-- (geog)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__CENTERMEAN(ST_ASGEOJSON($1)::VARCHAR(MAX))
$$ LANGUAGE sql;