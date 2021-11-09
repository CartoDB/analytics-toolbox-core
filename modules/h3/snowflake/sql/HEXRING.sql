----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._HEXRING
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }

    function setup() {
        @@SF_LIBRARY_HEXRING@@
        hexRing = h3Lib.hexRing;
        h3IsValid = h3Lib.h3IsValid;
    }

    if (typeof(hexRing) === "undefined" || typeof(h3IsValid) === "undefined") {
        setup();
    }

    if (!h3IsValid(ORIGIN)) {
        throw new Error('Invalid input origin')
    }

    return hexRing(ORIGIN, parseInt(SIZE));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.HEXRING
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@h3._HEXRING(ORIGIN, CAST(SIZE AS DOUBLE))
$$;