----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.HEXRING`
(origin STRING, size INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!origin || size == null || size < 0) {
        return null;
    }
    if (!h3Lib.h3IsValid(origin)) {
        return null;
    }
    try {
        return h3Lib.hexRing(origin, parseInt(size));
    } catch (error) {
        return null;
    }
""";