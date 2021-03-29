-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._TOCHILDREN`(index_lower INT64, index_upper INT64, resolution INT64)
    RETURNS ARRAY<INT64>
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

    return h3.h3ToChildren(h3IndexInput, Number(resolution)).map(h => '0x' + h);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.TOCHILDREN`(index INT64, resolution INT64)
    RETURNS ARRAY<INT64>
AS
(
    `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._TOCHILDREN`(index & 0x00000000FFFFFFFF, index >> 32, resolution)
);