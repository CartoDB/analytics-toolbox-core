-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__TOPARENT`(index_lower INT64, index_upper INT64, resolution INT64)
    RETURNS INT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (index_lower == null || index_upper == null)
        return null;
    const h3IndexInput = [Number(index_lower), Number(index_upper)];
    if (!h3.h3IsValid(h3IndexInput))
        return null;
    return '0x' + h3.h3ToParent([Number(index_lower), Number(index_upper)], Number(resolution));
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.TOPARENT`(index INT64, resolution INT64)
    RETURNS INT64
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__TOPARENT`(index & 0x00000000FFFFFFFF, index >> 32, resolution)
);