----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@placekey.PLACEKEY_ASH3
(placekey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!lib.placekeyIsValid(PLACEKEY))  {
        return null;
    }
    return lib.placekeyToH3(PLACEKEY);
$$;
