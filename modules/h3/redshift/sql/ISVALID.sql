----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@h3.ISVALID
(h3_index VARCHAR(15)) 
RETURNS BOOLEAN 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@h3Lib import h3_is_valid

    if h3_index is None:
        return False
    return h3_is_valid(h3_index)

$$ LANGUAGE plpythonu;