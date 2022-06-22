----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_to_geojson
    import json

    if quadbin is None:
        return None

    geojson = quadbin_to_geojson(quadbin)['geometry']
    return json.dumps(geojson)
$$ LANGUAGE plpythonu;
