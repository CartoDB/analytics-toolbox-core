----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._UNCOMPACT
(h3Array ARRAY, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (H3ARRAY == null || RESOLUTION == null || RESOLUTION < 0 || RESOLUTION > 15) {
        return [];
    }

    function setup() {
        @@SF_LIBRARY_UNCOMPACT@@
        uncompact = h3Lib.uncompact;
    }

    if (typeof(uncompact) === "undefined") {
        setup();
    }

    return uncompact(H3ARRAY, Number(RESOLUTION));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.UNCOMPACT
(h3Array ARRAY, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
(
    @@SF_PREFIX@@h3._UNCOMPACT(H3ARRAY, CAST(RESOLUTION AS DOUBLE))
)
$$;