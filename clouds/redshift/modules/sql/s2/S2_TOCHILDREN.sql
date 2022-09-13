----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__S2_TOCHILDREN
(id INT8, resolution INT4)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import to_children

    if id is None or resolution is None:
        raise Exception('NULL argument passed to UDF')
    
    return to_children(id, resolution)
    
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.__S2_TOCHILDREN
(id INT8)
RETURNS VARCHAR(MAX)
STABLE
AS $$
    from @@RS_LIBRARY@@.s2 import to_children

    if id is None:
        raise Exception('NULL argument passed to UDF')
    
    return to_children(id)
    
$$ LANGUAGE PLPYTHONU;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_TOCHILDREN
(INT8, INT4)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_SCHEMA@@.__S2_TOCHILDREN($1, $2))
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.S2_TOCHILDREN
(INT8)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_SCHEMA@@.__S2_TOCHILDREN($1))
$$ LANGUAGE SQL;
