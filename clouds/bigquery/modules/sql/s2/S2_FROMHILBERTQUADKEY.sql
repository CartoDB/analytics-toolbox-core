----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_FROMHILBERTQUADKEY`
(quadkey STRING)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_S2_BUCKET@@"]
)
AS """
    if (!quadkey) {
        throw new Error('NULL argument passed to UDF');
    }
    return s2Lib.keyToId(quadkey);
""";
