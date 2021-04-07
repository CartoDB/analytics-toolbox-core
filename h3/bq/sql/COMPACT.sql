-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.COMPACT`(h3Array ARRAY<STRING>)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (h3Array === null) {
        return null;
    }
    return h3.compact(h3Array);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.UNCOMPACT`(h3Array ARRAY<STRING>, resolution INT64)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (h3Array === null || resolution === null || resolution < 0 || resolution > 15) {
        return null;
    }
    return h3.uncompact(h3Array, Number(resolution));
""";
