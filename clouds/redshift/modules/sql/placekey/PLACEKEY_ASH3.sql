----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.PLACEKEY_ASH3
(placekey VARCHAR(19)) 
RETURNS VARCHAR 
STABLE
AS $$
    from @@RS_LIBRARY@@.placekey import placekey_to_h3, placekey_is_valid

    if not placekey_is_valid(placekey):
        return None
    return placekey_to_h3(placekey)
    
$$ LANGUAGE plpythonu;
