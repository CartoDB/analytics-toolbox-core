----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@placekey.ISVALID
(placekey STRING)
RETURNS BOOLEAN
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

    return placekeyLibGlobal.placekeyIsValid(PLACEKEY);
$$;