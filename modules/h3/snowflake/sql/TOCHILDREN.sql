----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._TOCHILDREN
(index STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    function setup() {
        @@SF_LIBRARY_TOCHILDREN@@
        h3ToChildren = h3Lib.h3ToChildren;
        h3IsValid = h3Lib.h3IsValid;
    }

    if (typeof(h3ToChildren) === "undefined" || typeof(h3IsValid) === "undefined") {
        setup();
    }

    if (!h3IsValid(INDEX)) {
        return [];
    }

    return h3ToChildren(INDEX, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.TOCHILDREN
(index STRING, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@h3._TOCHILDREN(INDEX, CAST(RESOLUTION AS DOUBLE))
$$;