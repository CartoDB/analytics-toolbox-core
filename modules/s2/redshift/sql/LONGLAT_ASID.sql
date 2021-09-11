----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.LONGLAT_ASID(
    longitude NUMERIC,
    latitude NUMERIC,
    resolution INTEGER
) 
RETURNS BIGINT 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import lnglat_as_id
    
    return lnglat_as_id(float(longitude), float(latitude), int(resolution))
    
$$ LANGUAGE plpythonu;
