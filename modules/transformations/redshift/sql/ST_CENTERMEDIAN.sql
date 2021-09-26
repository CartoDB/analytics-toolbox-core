----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.__CENTERMEDIAN
(geog VARCHAR(MAX), n_iter INT)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import center_median
    import geojson
    
    if geog is None:
        return None

    return str(center_median(geojson.loads(geog), n_iter))
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_CENTERMEDIAN
(GEOMETRY)
-- (geog)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__CENTERMEDIAN(ST_ASGEOJSON($1)::VARCHAR(MAX), 100)
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@transformations.ST_CENTERMEDIAN
(GEOMETRY, INT)
-- (geog)
RETURNS VARCHAR(MAX)
-- RETURNS GEOMETRY
IMMUTABLE
AS $$
    SELECT @@RS_PREFIX@@transformations.__CENTERMEDIAN(ST_ASGEOJSON($1)::VARCHAR(MAX), $2)
$$ LANGUAGE sql;