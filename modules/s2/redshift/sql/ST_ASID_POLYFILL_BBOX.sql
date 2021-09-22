----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX(
    min_longitude FLOAT,
    min_latitude FLOAT,
    max_longitude FLOAT,
    max_latitude FLOAT,
    min_resolution INTEGER,
    max_resolution INTEGER
) 
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import polyfill_bbox

    to_check = [min_longitude, min_latitude, max_longitude,
                max_latitude, min_resolution, max_resolution]
    for arg in to_check:
        if arg is None:
            raise Exception('NULL argument passed to UDF')
    
    return polyfill_bbox(min_longitude, min_latitude, max_longitude,
                         max_latitude, min_resolution, max_resolution)
    
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX(
    min_longitude FLOAT,
    min_latitude FLOAT,
    max_longitude FLOAT,
    max_latitude FLOAT
) 
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import polyfill_bbox


    to_check = [min_longitude, min_latitude, max_longitude, max_latitude]
    for arg in to_check:
        if arg is None:
            raise Exception('NULL argument passed to UDF')
    
    
    return polyfill_bbox(min_longitude, min_latitude, max_longitude, max_latitude)
    
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_ASID_POLYFILL_BBOX(
    min_longitude FLOAT,
    min_latitude FLOAT,
    max_longitude FLOAT,
    max_latitude FLOAT,
    min_resolution INTEGER,
    max_resolution INTEGER
) 
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX($1, $2, $3, $4, $5, $6))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_ASID_POLYFILL_BBOX(
    min_longitude FLOAT,
    min_latitude FLOAT,
    max_longitude FLOAT,
    max_latitude FLOAT
) 
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX($1, $2, $3, $4))
$$ LANGUAGE sql;
