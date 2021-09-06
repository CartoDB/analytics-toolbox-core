----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@placekey.ISVALID
(placekey VARCHAR(19)) 
RETURNS BOOLEAN 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@placekeyLib import placekey_is_valid

    if placekey is None:
        return False
    return placekey_is_valid(placekey)

$$ LANGUAGE plpythonu;