----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_RESOLUTION`
(index STRING)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!index) {
        return null;
    }

    if (!lib.h3.h3IsValid(index)) {
        return null;
    }

    return lib.h3.h3GetResolution(index);
""";
