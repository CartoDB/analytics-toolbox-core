----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._HEXRING
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_HEXRING@@

    if (!ORIGIN || SIZE == null || SIZE < 0) {
        return null;
    }

    if (!h3Lib.h3IsValid(ORIGIN)) {
        return null;
    }

    try {
        return h3Lib.hexRing(ORIGIN, parseInt(SIZE));
    } catch (error) {
        return null;
    }
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.HEXRING
(origin STRING, size INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@h3._HEXRING(ORIGIN, CAST(SIZE AS DOUBLE))
$$;