----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.QUADINT_SIBLING`
(quadint INT64, direction STRING)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (quadint == null || !direction) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.sibling(quadint,direction).toString();  
""";