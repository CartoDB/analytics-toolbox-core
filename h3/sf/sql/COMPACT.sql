-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._COMPACT`(h3Array ARRAY<STRING>)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (h3Array === null) {
        return null;
    }
    return h3.compact(h3Array).map(h => '0x' + h);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.COMPACT`(h3Array ARRAY<INT64>)
    RETURNS ARRAY<INT64>
AS
((
    SELECT `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._COMPACT`(ARRAY_AGG(`@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.H3_ASHEX`(x))) FROM unnest(h3Array) x
));


CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._UNCOMPACT`(h3Array ARRAY<STRING>, resolution INT64)
    RETURNS ARRAY<INT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (h3Array === null || resolution === null || resolution < 0 || resolution > 15) {
        return null;
    }
    return h3.uncompact(h3Array, Number(resolution)).map(h => '0x' + h);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.UNCOMPACT`(h3Array ARRAY<INT64>, resolution INT64)
    RETURNS ARRAY<INT64>
AS
((
    SELECT `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@._UNCOMPACT`(ARRAY_AGG(`@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.H3_ASHEX`(x)), resolution) FROM unnest(h3Array) x
));