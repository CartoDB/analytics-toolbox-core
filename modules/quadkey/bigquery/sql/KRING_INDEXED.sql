----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.KRING_INDEXED`
(quadint INT64, distance INT64
RETURNS ARRAY<STRUCT<x INT64, y INT64, idx INT64>>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS R"""
if (quadint == null) {
        throw new Error('NULL argument passed to UDF');
    }
    if (distance == null) {
        distance = 1;
    }
    return quadkeyLib.kring_indexed(quadint, Number(distance));
""";