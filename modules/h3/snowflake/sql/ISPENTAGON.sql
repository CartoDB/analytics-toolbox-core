----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.ISPENTAGON
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return false;
    }

    function setup() {
        @@SF_LIBRARY_ISPENTAGON@@
        h3IsPentagon = h3Lib.h3IsPentagon;
    }

    if (typeof(h3IsPentagon) === "undefined") {
        setup();
    }

    return h3IsPentagon(INDEX);
$$;