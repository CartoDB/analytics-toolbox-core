----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX
(min_longitude FLOAT8, max_longitude FLOAT8, min_latitude FLOAT8,
 max_latitude FLOAT8, min_resolution INT4, max_resolution INT4)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import polyfill_bbox

    to_check = [min_longitude, max_longitude, min_latitude,
                max_latitude, min_resolution, max_resolution]
    for arg in to_check:
        if arg is None:
            raise Exception('NULL argument passed to UDF')
    
    return polyfill_bbox(min_longitude, max_longitude, min_latitude,
                         max_latitude, min_resolution, max_resolution)
    
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX
(min_longitude FLOAT8, max_longitude FLOAT8, min_latitude FLOAT8,
 max_latitude FLOAT8)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import polyfill_bbox

    to_check = [min_longitude, max_longitude, min_latitude, max_latitude]
    for arg in to_check:
        if arg is None:
            raise Exception('NULL argument passed to UDF')
    
    
    return polyfill_bbox(min_longitude, max_longitude, min_latitude, max_latitude)
    
$$ LANGUAGE plpythonu;


CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_ASID_POLYFILL_BBOX
(min_longitude FLOAT8, max_longitude FLOAT8, min_latitude FLOAT8,
 max_latitude FLOAT8, min_resolution INT4, max_resolution INT4)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX($1, $2, $3, $4, $5, $6))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.ST_ASID_POLYFILL_BBOX
(min_longitude FLOAT8, max_longitude FLOAT8, min_latitude FLOAT8,
 max_latitude FLOAT8)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@s2._ST_ASID_POLYFILL_BBOX($1, $2, $3, $4))
$$ LANGUAGE sql;
