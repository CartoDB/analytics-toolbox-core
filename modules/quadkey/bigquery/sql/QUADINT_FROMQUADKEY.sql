----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.QUADINT_FROMQUADKEY`
(quadkey STRING)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return quadkeyLib.quadintFromQuadkey(quadkey).toString();
""";