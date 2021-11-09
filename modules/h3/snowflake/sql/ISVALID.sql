----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.ISVALID
(index STRING)
RETURNS BOOLEAN
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return false;
    }

    function setup() {
        @@SF_LIBRARY_ISVALID@@
        h3IsValid = h3Lib.h3IsValid;
    }

    if (typeof(h3IsValid) === "undefined") {
        setup();
    }

    return h3IsValid(INDEX);
$$;