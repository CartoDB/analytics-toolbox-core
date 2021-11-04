----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADINT_KRING
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (ORIGIN == null || ORIGIN <= 0) {
        throw new Error('Invalid input origin')
    }

    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }

    return quadkeyLib.kRing(ORIGIN, parseInt(SIZE));
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_KRING
(origin BIGINT, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    _QUADINT_KRING(CAST(ORIGIN AS STRING), CAST(SIZE AS DOUBLE))
$$;