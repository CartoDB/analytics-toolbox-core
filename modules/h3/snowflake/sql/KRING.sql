----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._KRING
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_KRING@@

    if (!ORIGIN || SIZE == null || SIZE < 0) {
        return null;
    }

    if (!h3Lib.h3IsValid(ORIGIN)) {
        return null;
    }

    return h3Lib.kRing(ORIGIN, parseInt(SIZE));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.KRING
(origin STRING, size INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@h3._KRING(ORIGIN, CAST(SIZE AS DOUBLE))
$$;