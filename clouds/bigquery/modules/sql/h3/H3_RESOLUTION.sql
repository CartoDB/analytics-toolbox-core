----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_RESOLUTION`
(index STRING)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_H3_BUCKET@@"]
)
AS """
    if (!index) {
        return null;
    }

    if (!h3Lib.h3IsValid(index)) {
        return null;
    }

    return h3Lib.h3GetResolution(index);
""";
