----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._TOPARENT
(index STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_TOPARENT@@
        h3ToParent = h3Lib.h3ToParent;
        h3IsValid = h3Lib.h3IsValid;
    }

    if (typeof(h3ToParent) === "undefined" || typeof(h3IsValid) === "undefined") {
        setup();
    }

    if (!h3IsValid(INDEX)) {
        return null;
    }

    return h3ToParent(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.TOPARENT
(index STRING, resolution INT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_PREFIX@@h3._TOPARENT(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;