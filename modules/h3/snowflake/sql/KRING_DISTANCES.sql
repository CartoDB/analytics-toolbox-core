----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@h3._KRING_DISTANCES
(origin STRING, size DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (SIZE == null || SIZE < 0) {
        throw new Error('Invalid input size')
    }

    function setup() {
        @@SF_LIBRARY_KRING_DISTANCES@@
        kRingDistances = h3Lib.kRingDistances;
        h3IsValid = h3Lib.h3IsValid;
    }

    if (typeof(kRingDistances) === "undefined" || typeof(h3IsValid) === "undefined") {
        setup();
    }

    if (!h3IsValid(ORIGIN)) {
        throw new Error('Invalid input origin')
    }

    const kringDistances = kRingDistances(ORIGIN, parseInt(SIZE));
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
IMMUTABLE
AS $$
    @@SF_PREFIX@@h3._KRING_DISTANCES(ORIGIN, CAST(SIZE AS DOUBLE))
$$;