----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __H3_KRING_DISTANCES
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }  

    @@SF_LIBRARY_KRING_DISTANCES@@

    if (!h3Lib.h3IsValid(ORIGIN)) {
        throw new Error('Invalid input origin')
    }

    const kringDistances = h3Lib.kRingDistances(ORIGIN, parseInt(SIZE));
    const output = [];
    for (let distance = 0; distance <= parseInt(SIZE); distance++) {
        const indexes = kringDistances[distance];
        for (const index of indexes) {
            output.push({ index, distance });
        }
    }
    return output;
$$;

CREATE OR REPLACE SECURE FUNCTION H3_KRING_DISTANCES
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    __H3_KRING_DISTANCES(ORIGIN, CAST(SIZE AS DOUBLE))
$$;