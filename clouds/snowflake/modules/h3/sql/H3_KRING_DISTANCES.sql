----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._H3_KRING_DISTANCES
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }  

    @@SF_LIBRARY_H3_KRING_DISTANCES@@

    if (!h3_kring_distancesLib.h3IsValid(ORIGIN)) {
        throw new Error('Invalid input origin')
    }

    const kringDistances = h3_kring_distancesLib.kRingDistances(ORIGIN, parseInt(SIZE));
    const output = [];
    for (let distance = 0; distance <= parseInt(SIZE); distance++) {
        const indexes = kringDistances[distance];
        for (const index of indexes) {
            output.push({ index, distance });
        }
    }
    return output;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_KRING_DISTANCES
(origin STRING, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._H3_KRING_DISTANCES(ORIGIN, CAST(SIZE AS DOUBLE))
$$;