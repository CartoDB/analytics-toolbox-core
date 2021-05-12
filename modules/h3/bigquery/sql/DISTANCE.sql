----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@h3.DISTANCE`
(index1 STRING, index2 STRING)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS
"""
    if (!index1 || !index2)
        return null;
    let dist = lib.h3Distance(index1, index2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
""";
