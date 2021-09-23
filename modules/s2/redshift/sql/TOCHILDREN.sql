----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2._TOCHILDREN
(id INT8, resolution INT4)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import to_children

    if id is None or resolution is None:
        raise Exception('NULL argument passed to UDF')
    
    return to_children(id, resolution)
    
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2._TOCHILDREN
(id INT8)
RETURNS VARCHAR(MAX)
IMMUTABLE
AS $$
    from @@RS_PREFIX@@s2Lib import to_children

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return to_children(id)
    
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.TOCHILDREN
(INT8, INT4)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@s2._TOCHILDREN($1, $2))
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@s2.TOCHILDREN
(INT8)
RETURNS SUPER
IMMUTABLE
AS $$
    SELECT json_parse(@@RS_PREFIX@@s2._TOCHILDREN($1))
$$ LANGUAGE sql;
