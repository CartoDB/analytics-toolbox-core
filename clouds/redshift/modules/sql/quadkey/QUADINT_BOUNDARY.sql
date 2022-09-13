----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__QUADINT_BOUNDARY
(quadint BIGINT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.quadkey import quadint_to_geojson
    import json

    if quadint is None:
        raise Exception('NULL argument passed to UDF')

    geojson = quadint_to_geojson(quadint)['geometry']
    return json.dumps(geojson)
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADINT_BOUNDARY
(BIGINT)
-- (quadint)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    SELECT @@RS_SCHEMA@@.__QUADINT_BOUNDARY($1)
$$ LANGUAGE SQL;
