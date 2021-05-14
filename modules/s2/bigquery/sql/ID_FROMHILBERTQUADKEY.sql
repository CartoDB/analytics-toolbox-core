----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.ID_FROMHILBERTQUADKEY`
(quadkey STRING)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!quadkey) {
        throw new Error('NULL argument passed to UDF');
    }
    return lib.keyToId(quadkey);
""";
