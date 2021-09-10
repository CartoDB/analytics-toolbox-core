----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@h3.LONGLAT_ASQUADINT
(longitude FLOAT64, latitude FLOAT64, resolution INT)
-- (longitude, latitude, resolution)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_PREFIX@@h3Lib import geo_to_h3
    
    if longitude is None or latitude is None or resolution is None:
        raise Exception('NULL argument passed to UDF')

    return geo_to_h3(latitude, longitude, resolution);

$$ LANGUAGE plpythonu;