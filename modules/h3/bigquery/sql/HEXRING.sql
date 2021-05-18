----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.HEXRING`
(index STRING, distance INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!index || distance == null || distance < 0) {
        return null;
    }

    if (!h3Lib.h3IsValid(index)) {
        return null;
    }

    try {
        return h3Lib.hexRing(index, parseInt(distance));
    } catch (error) {
        return null;
    }
""";