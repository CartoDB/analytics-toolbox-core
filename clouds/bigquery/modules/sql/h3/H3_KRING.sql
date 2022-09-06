----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_KRING`
(origin STRING, size INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!lib.h3.h3IsValid(origin)) {
        throw new Error('Invalid input origin')
    }
    if (size == null || size < 0) {
        throw new Error('Invalid input size')
    }
    return lib.h3.kRing(origin, parseInt(size));
""";