----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.PLACEKEY_TOH3
(placekey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_PLACEKEY@@

    if (!placekeyLib.placekeyIsValid(PLACEKEY)) {
        return null;
    }
    return placekeyLib.placekeyToH3(PLACEKEY);
$$;
