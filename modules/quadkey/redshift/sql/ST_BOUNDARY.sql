----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey._GEOJSONBOUNDARY_FROMQUADINT
(quadint BIGINT)
RETURNS VARCHAR
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadintToGeoJSON
    
    if quadint is None:
        raise Exception('NULL argument passed to UDF')

    geojson = quadintToGeoJSON(quadint)['geometry'];
    return geojson
$$ LANGUAGE plpythonu;

-- CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.ST_BOUNDARY
-- (BIGINT)
-- -- (quadint)
-- RETURNS GEOMETRY
-- IMMUTABLE
-- AS $$
--     SELECT ST_GEOMFROMGEOJSON(@@RS_PREFIX@@quadkey._ST_BOUNDARY($1))
-- $$ LANGUAGE sql;