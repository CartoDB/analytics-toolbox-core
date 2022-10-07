----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__CLUSTERKMEANS
(geom VARCHAR(MAX), numberofClusters INT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.clustering import clusterkmeans
    if geom is None:
        return None
    return clusterkmeans(geom, numberofClusters)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_CLUSTERKMEANS
(GEOMETRY)
-- (geom)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_SCHEMA@@.__CLUSTERKMEANS(ST_ASGEOJSON($1), SQRT(ST_NPoints($1)/2)::INT))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.ST_CLUSTERKMEANS
(GEOMETRY, INT)
-- (geom, numberofClusters)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_SCHEMA@@.__CLUSTERKMEANS(ST_ASGEOJSON($1), $2))
$$ LANGUAGE sql;
