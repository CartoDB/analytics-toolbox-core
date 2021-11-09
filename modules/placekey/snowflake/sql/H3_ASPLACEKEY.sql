----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@placekey._H3_ASPLACEKEY
(h3Index STRING)
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

    return placekeyLibGlobal.h3ToPlacekey(H3INDEX);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@placekey.H3_ASPLACEKEY
(h3Index STRING)
RETURNS STRING
IMMUTABLE
AS $$
    IFF(@@SF_PREFIX@@h3.ISVALID(H3INDEX),
      @@SF_PREFIX@@placekey._H3_ASPLACEKEY(H3INDEX),
      null)
$$;