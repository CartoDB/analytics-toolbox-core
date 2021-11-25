----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __QUADINT_KRING_DISTANCES
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (ORIGIN == null || ORIGIN <= 0) {
        throw new Error('Invalid input origin')
    }

    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }

    @@SF_LIBRARY_CONTENT@@

    return quadkeyLib.kRingDistances(ORIGIN, parseInt(SIZE));
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    __QUADINT_KRING_DISTANCES(CAST(ORIGIN AS STRING), CAST(SIZE AS DOUBLE))
$$;