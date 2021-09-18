----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._KRING_DISTANCES
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_KRING_DISTANCES@@

    if (!ORIGIN || SIZE == null || SIZE < 0) {
        return null;
    }

    if (!h3Lib.h3IsValid(ORIGIN)) {
        return null;
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

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@h3.KRING_DISTANCES
(origin STRING, size INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@h3._KRING_DISTANCES(ORIGIN, CAST(SIZE AS DOUBLE))
$$;