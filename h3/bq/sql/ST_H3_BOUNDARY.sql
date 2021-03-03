-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ST_H3_BOUNDARY`(index_lower INT64, index_upper INT64)
    RETURNS STRING
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
    const coords = h3.h3ToGeoBoundary(h3IndexInput, true);
    let output = `POLYGON((`;
    for (let i = 0; i < coords.length - 1; i++) {
        output += coords[i][0] + ` ` + coords[i][1] + `,`;
    }
    output += coords[coords.length - 1][0] + ` ` + coords[coords.length - 1][1] + `))`;
    return output;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.ST_H3_BOUNDARY`(index INT64)
    RETURNS GEOGRAPHY
AS
(
    ST_GEOGFROMTEXT(`@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ST_H3_BOUNDARY`(index & 0x00000000FFFFFFFF, index >> 32))
);