----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_KRING_DISTANCES(
    origin VARCHAR(16),
    size INT
)
RETURNS JSON[]
AS
$BODY$
    if (size == null || size < 0) {
        throw new Error('Invalid input size')
    }

    @@PG_LIBRARY_H3@@

    if (!h3Lib.h3IsValid(origin)) {
        throw new Error('Invalid input origin')
    }

    const kringDistances = h3Lib.kRingDistances(origin, parseInt(size));
    const output = [];
    for (let distance = 0; distance <= parseInt(size); distance++) {
        const indexes = kringDistances[distance];
        for (const index of indexes) {
            output.push({ index, distance });
        }
    }
    return output;
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
