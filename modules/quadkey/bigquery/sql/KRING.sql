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
    if (!origin || size == null || size < 0) {
        return null;
    }
    return quadkeyLib.kRing(origin, Number(size));
""";