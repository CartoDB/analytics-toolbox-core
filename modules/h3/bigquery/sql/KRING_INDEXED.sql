----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.KRING_INDEXED`
(idx STRING, distance INT64)
RETURNS ARRAY<STRUCT<distance INT64, idx ARRAY<STRING>>>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
if (!idx || distance == null || distance < 0) {
        return null;
    }
    if (!h3Lib.h3IsValid(idx)) {
        return null;
    }
    return Array.from(Array(parseInt(distance)).keys()).map(x => h3Lib.hexRing(idx, x).map(idx => ({idx:idx, distance:x}))).flat();
""";