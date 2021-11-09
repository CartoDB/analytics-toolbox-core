----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._KRING
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }

    function setup() {
        @@SF_LIBRARY_KRING@@
        kRing = h3Lib.kRing;
        h3IsValid = h3Lib.h3IsValid;
    }

    if (typeof(kRing) === "undefined" || typeof(h3IsValid) === "undefined") {
        setup();
    }

    if (!h3IsValid(ORIGIN)) {
        throw new Error('Invalid input origin')
    }

    return kRing(ORIGIN, parseInt(SIZE));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.KRING
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@h3._KRING(ORIGIN, CAST(SIZE AS DOUBLE))
$$;