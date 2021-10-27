----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.__GEOJSONBOUNDARY_FROMQUADINT
(quadint BIGINT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadint_to_geojson
    
    if quadint is None:
        raise Exception('NULL argument passed to UDF')

    geojson = quadint_to_geojson(quadint)['geometry']
    return str(geojson)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.ST_BOUNDARY
(BIGINT)
-- (quadint)
RETURNS VARCHAR
-- RETURNS GEOMETRY
STABLE
AS $$
    SELECT @@RS_PREFIX@@quadkey.__GEOJSONBOUNDARY_FROMQUADINT($1)
    -- SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@quadkey.__GEOJSONBOUNDARY_FROMQUADINT($1))
$$ LANGUAGE sql;