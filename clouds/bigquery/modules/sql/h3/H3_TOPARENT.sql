----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_TOPARENT`
(index STRING, resolution INT64)
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
    return coreLib.h3.h3ToParent(index, Number(resolution));
""";