----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@placekey.H3_ASPLACEKEY
(h3_index VARCHAR(15)) 
RETURNS VARCHAR 
IMMUTABLE
AS $$
    from @@RS_PREFIX@@placekeyLib import h3_to_placekey, h3_is_valid
    
    if not h3_is_valid(h3_index):
        return None
    return h3_to_placekey(h3_index)
    
$$ LANGUAGE plpythonu;