----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__H3_CENTER`
(index STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!index) {
        return null;
    }

    if (!coreLib.h3.h3IsValid(index)) {
        return null;
    }

    const center = coreLib.h3.h3ToGeo(index);
    return `POINT(`+center[1] + ` ` + center[0] + `)`;
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_CENTER`
(index STRING)
RETURNS GEOGRAPHY
AS (
    SAFE.ST_GEOGFROMTEXT(`@@BQ_DATASET@@.__H3_CENTER`(index))
);