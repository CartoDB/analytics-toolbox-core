----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@placekey.PLACEKEY_ISVALID
(placekey VARCHAR(19)) 
RETURNS BOOLEAN 
STABLE
AS $$
    from @@RS_PREFIX@@placekeyLib import placekey_is_valid

    return placekey_is_valid(placekey)

$$ LANGUAGE plpythonu;