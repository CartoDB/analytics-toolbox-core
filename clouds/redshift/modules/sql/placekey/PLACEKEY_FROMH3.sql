----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.PLACEKEY_FROMH3
(h3_index VARCHAR(15))
RETURNS VARCHAR
STABLE
AS $$
    from @@RS_LIBRARY@@.placekey import h3_to_placekey, h3_is_valid
    
    if not h3_is_valid(h3_index):
        return None
    return h3_to_placekey(h3_index)
    
$$ LANGUAGE PLPYTHONU;
