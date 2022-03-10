----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__GEOJSONTOWKT
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@transformationsLib import wkt_from_geojson

    return wkt_from_geojson(geom)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.__ST_GEOMFROMGEOJSON
(VARCHAR(MAX))
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_PREFIX@@carto.__GEOJSONTOWKT($1), 4326)
$$ LANGUAGE sql;