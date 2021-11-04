----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION PLACEKEY_ISVALID
(placekey STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    return placekeyLib.placekeyIsValid(PLACEKEY);
$$;