----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION PLACEKEY_ASH3
(placekey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!placekeyLib.placekeyIsValid(PLACEKEY)) {
        return null;
    }
    return placekeyLib.placekeyToH3(PLACEKEY);
$$;