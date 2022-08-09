----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__H3_BOUNDARY`
(index STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!index) {
        return null;
    }

    if (!h3Lib.h3IsValid(index)) {
        return null;
    }

    const coords = h3Lib.h3ToGeoBoundary(index, true);
    let output = `POLYGON((`;
    for (let i = 0; i < coords.length - 1; i++) {
        output += coords[i][0] + ` ` + coords[i][1] + `,`;
    }
    output += coords[coords.length - 1][0] + ` ` + coords[coords.length - 1][1] + `))`;
    return output;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.H3_BOUNDARY`
(index STRING)
RETURNS GEOGRAPHY
AS (
    SAFE.ST_GEOGFROMTEXT(`@@BQ_PREFIX@@carto.__H3_BOUNDARY`(index), make_valid => TRUE)
);