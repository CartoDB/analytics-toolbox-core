----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@placekey.PLACEKEY_ASH3
(placekey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    function setup() {
        @@SF_LIBRARY_CONTENT@@
        placekeyLibGlobal = placekeyLib;
    }

    if (typeof(placekeyLibGlobal) === "undefined") {
        setup();
    }

    if (!placekeyLibGlobal.placekeyIsValid(PLACEKEY)) {
        return null;
    }
    return placekeyLibGlobal.placekeyToH3(PLACEKEY);
$$;