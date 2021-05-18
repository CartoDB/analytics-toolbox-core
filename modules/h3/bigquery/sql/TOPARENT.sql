----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.TOPARENT`
(index STRING, resolution INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!index) {
        return null;
    }
    if (!h3Lib.h3IsValid(index)) {
        return null;
    }
    return h3Lib.h3ToParent(index, Number(resolution));
""";