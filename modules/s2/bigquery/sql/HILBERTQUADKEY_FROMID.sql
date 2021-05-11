----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.HILBERTQUADKEY_FROMID`
(id INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (id == null) {
        throw new Error('NULL argument passed to UDF');
    }

    return lib.idToKey(id);
""";
