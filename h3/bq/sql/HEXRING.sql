-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.HEXRING`(index STRING, distance INT64)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (!index || distance == null || distance < 0)
        return null;

    if (!h3.h3IsValid(index))
        return null;

    try {
        return h3.hexRing(index, parseInt(distance));
    } catch (error) {
        return null;
    }
""";
