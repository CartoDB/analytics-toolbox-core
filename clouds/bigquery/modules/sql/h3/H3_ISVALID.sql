----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_ISVALID`
(index STRING)
RETURNS BOOLEAN
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_H3_BUCKET@@"]
)
AS """
    if (!index) {
        return false;
    }
    return h3Lib.h3IsValid(index);
""";
