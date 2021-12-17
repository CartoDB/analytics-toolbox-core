----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.H3_KRING`
(origin STRING, size INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!h3Lib.h3IsValid(origin)) {
        throw new Error('Invalid input origin')
    }
    if (size == null || size < 0) {
        throw new Error('Invalid input size')
    }
    return h3Lib.kRing(origin, parseInt(size));
""";