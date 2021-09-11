----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.TOPARENT(
    id BIGINT,
    resolution INTEGER
) 
RETURNS BIGINT 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import to_parent
    
    return to_parent(long(id), int(resolution))
    
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.TOPARENT(
    id BIGINT
)
RETURNS BIGINT 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import to_parent
    
    return to_parent(long(id))
    
$$ LANGUAGE plpythonu;
