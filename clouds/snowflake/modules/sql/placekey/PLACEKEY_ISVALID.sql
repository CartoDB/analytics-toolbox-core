----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.PLACEKEY_ISVALID
(placekey STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_PLACEKEY@@

    return placekeyLib.placekeyIsValid(PLACEKEY);
$$;
