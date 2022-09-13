----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__GEOJSONTOWKT
(geom VARCHAR(MAX))
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.transformations import wkt_from_geojson

    return wkt_from_geojson(geom)
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__ST_GEOMFROMGEOJSON
(VARCHAR(MAX))
-- (geom)
RETURNS GEOMETRY
STABLE
AS $$
    SELECT ST_GEOMFROMTEXT(@@RS_SCHEMA@@.__GEOJSONTOWKT($1), 4326)
$$ LANGUAGE SQL;
