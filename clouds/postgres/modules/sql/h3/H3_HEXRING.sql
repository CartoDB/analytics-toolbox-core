----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.H3_HEXRING(
    origin VARCHAR(16),
    size INT
)
RETURNS VARCHAR(16)[]
AS
$BODY$
    if (size == null || size < 0) {
        throw new Error('Invalid input size')
    }

    @@PG_LIBRARY_H3@@

    if (!h3Lib.h3IsValid(origin)) {
        throw new Error('Invalid input origin')
    }

    return h3Lib.hexRing(origin, parseInt(size));
$BODY$
LANGUAGE plv8 IMMUTABLE PARALLEL SAFE;
