----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_FROMLONGLAT
(longitude FLOAT8, latitude FLOAT8, resolution INT4)
RETURNS INT8
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import longlat_as_int64_id

    if longitude is None or latitude is None or resolution is None:
        raise Exception('NULL argument passed to UDF')
    
    return longlat_as_int64_id(longitude, latitude, resolution)
    
$$ LANGUAGE PLPYTHONU;
