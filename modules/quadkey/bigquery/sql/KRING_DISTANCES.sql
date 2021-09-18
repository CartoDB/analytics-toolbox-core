----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.KRING_DISTANCES`
(origin INT64, size INT64)
RETURNS ARRAY<STRUCT<index INT64, distance INT64>>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (origin == null) {
        throw new Error('NULL argument passed to UDF');
    }
    if (size == null) {
        size = 1;
    }
    return quadkeyLib.kringDistances(origin, Number(size));
""";