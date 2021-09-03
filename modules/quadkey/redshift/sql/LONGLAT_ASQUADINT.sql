----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.LONGLAT_ASQUADINT
(longitude FLOAT8, latitude FLOAT8, resolution INT)
-- (longitude, latitude, resolution)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@quadkeyLib import quadintFromLocation
    
    if longitude is None or latitude is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return quadintFromLocation(longitude, latitude, resolution)
$$ LANGUAGE plpythonu;
