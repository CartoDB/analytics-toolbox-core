----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.KRING`
(origin INT64, size INT64)
RETURNS ARRAY<INT64>
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
    return quadkeyLib.kring(origin, Number(size));
""";