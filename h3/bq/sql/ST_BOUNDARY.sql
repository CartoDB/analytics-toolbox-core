-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ST_BOUNDARY`(index STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@H3_BQ_LIBRARY@@"])
AS
"""
    if (!index)
        return null;
        
    if (!h3.h3IsValid(index))
        return null;
        
    const coords = h3.h3ToGeoBoundary(index, true);
    let output = `POLYGON((`;
    for (let i = 0; i < coords.length - 1; i++) {
        output += coords[i][0] + ` ` + coords[i][1] + `,`;
    }
    output += coords[coords.length - 1][0] + ` ` + coords[coords.length - 1][1] + `))`;
    return output;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.ST_BOUNDARY`(index STRING)
    RETURNS GEOGRAPHY
AS
(
    SAFE.ST_GEOGFROMTEXT(`@@BQ_PROJECTID@@.@@BQ_DATASET_H3@@.__ST_BOUNDARY`(index))
);