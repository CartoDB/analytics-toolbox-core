----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.H3_UNCOMPACT`
(h3Array ARRAY<STRING>, resolution INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (h3Array === null || resolution === null || resolution < 0 || resolution > 15) {
        return null;
    }
    return h3Lib.uncompact(h3Array, Number(resolution));
""";