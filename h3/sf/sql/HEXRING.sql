-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._HEXRING`(index_lower INT64, index_upper INT64, distance INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (index_lower == null || index_upper == null || distance == null || distance < 0)
        return null;
    const h3IndexInput = [Number(index_lower), Number(index_upper)];
    if (!h3.h3IsValid(h3IndexInput))
        return null;

    try {
        return h3.hexRing(h3IndexInput, parseInt(distance)).map(h => '0x' + h);
    } catch (error) {
        return null;
    }
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.HEXRING`(index INT64, distance INT64)
    RETURNS ARRAY<INT64>
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._HEXRING`(index & 0x00000000FFFFFFFF, index >> 32, distance)
);