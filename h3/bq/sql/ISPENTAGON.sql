-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ISPENTAGON`(index_lower INT64, index_upper INT64)
    RETURNS BOOLEAN
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (index_lower == null || index_upper == null)
        return false;
    return h3.h3IsPentagon([Number(index_lower), Number(index_upper)]);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.ISPENTAGON`(index INT64)
    RETURNS BOOLEAN
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ISPENTAGON`(index & 0x00000000FFFFFFFF, index >> 32)
);