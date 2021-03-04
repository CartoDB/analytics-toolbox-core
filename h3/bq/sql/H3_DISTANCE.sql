-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__H3_DISTANCE`(index_lower1 INT64, index_upper1 INT64, index_lower2 INT64, index_upper2 INT64)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (index_lower1 == null || index_upper1 == null || index_lower2 == null || index_upper2 == null)
        return null;
    const index1 = [Number(index_lower1), Number(index_upper1)];
    const index2 = [Number(index_lower2), Number(index_upper2)];
    let dist = h3.h3Distance(index1, index2);
    if (dist < 0) {
        dist = null;
    }
    return dist;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.H3_DISTANCE`(index1 INT64, index2 INT64)
    RETURNS INT64
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__H3_DISTANCE`(
        index1 & 0x00000000FFFFFFFF, index1 >> 32,
        index2 & 0x00000000FFFFFFFF, index2 >> 32
    )
);