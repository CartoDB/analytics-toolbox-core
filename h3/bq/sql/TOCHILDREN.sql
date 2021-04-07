-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.TOCHILDREN`(index STRING, resolution INT64)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (!index)
        return null;

    if (!h3.h3IsValid(index))
        return null;

    return h3.h3ToChildren(index, Number(resolution));
""";
