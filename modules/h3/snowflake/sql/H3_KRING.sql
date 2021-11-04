----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _H3_KRING
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_KRING@@

    if (!h3Lib.h3IsValid(ORIGIN)) {
        throw new Error('Invalid input origin')
    }

    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }

    return h3Lib.kRing(ORIGIN, parseInt(SIZE));
$$;

CREATE OR REPLACE SECURE FUNCTION H3_KRING
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    _H3_KRING(ORIGIN, CAST(SIZE AS DOUBLE))
$$;