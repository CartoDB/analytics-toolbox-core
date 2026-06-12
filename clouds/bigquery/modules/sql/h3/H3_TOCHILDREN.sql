----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_TOCHILDREN`
(index STRING, resolution INT64)
RETURNS ARRAY<STRING>
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
    return h3Lib.h3ToChildren(index, Number(resolution));
""";
