-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.DISTANCE`(index1 STRING, index2 STRING)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (!index1 || !index2)
        return null;
    let dist = h3.h3Distance(index1, index2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
""";