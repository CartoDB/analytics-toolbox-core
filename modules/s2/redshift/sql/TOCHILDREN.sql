----------------------------
-- Copyright (C) 2021 CARTO
----------------------------


-- This functionality is blocked by the fact that Redshift
-- has a 256 max character limit even for text types
-- so just one zoom level higher breaks he limit
CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.TOCHILDREN(
    id BIGINT,
    resolution INTEGER
) 
RETURNS VARCHAR(MAX) 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import to_children
    
    return to_children(long(id), int(resolution))
    
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.TOCHILDREN(
    id BIGINT
)
RETURNS VARCHAR(MAX) 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import to_children
    
    return to_children(long(id))
    
$$ LANGUAGE plpythonu;
