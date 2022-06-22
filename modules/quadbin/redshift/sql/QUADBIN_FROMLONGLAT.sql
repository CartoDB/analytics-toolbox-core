----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADBIN_FROMLONGLAT
(longitude FLOAT8, latitude FLOAT8, resolution INT)
RETURNS BIGINT
STABLE
AS $$
    from @@RS_PREFIX@@quadbinLib import quadbin_from_location
    
    if longitude is None or latitude is None or resolution is None:
        return None

    return quadbin_from_location(longitude, latitude, resolution)
$$ LANGUAGE plpythonu;
