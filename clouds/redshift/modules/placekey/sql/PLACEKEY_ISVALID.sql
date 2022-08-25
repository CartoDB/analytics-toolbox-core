----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.PLACEKEY_ISVALID
(placekey VARCHAR(19)) 
RETURNS BOOLEAN 
STABLE
AS $$
    from @@RS_LIBRARY@@.placekey import placekey_is_valid

    return placekey_is_valid(placekey)

$$ LANGUAGE plpythonu;