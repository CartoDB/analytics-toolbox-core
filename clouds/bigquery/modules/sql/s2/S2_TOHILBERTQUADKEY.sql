----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_TOHILBERTQUADKEY`
(id INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_S2_BUCKET@@"]
)
AS """
    if (id == null) {
        throw new Error('NULL argument passed to UDF');
    }
    return s2Lib.idToKey(id);
""";
