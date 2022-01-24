----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADINT_RESOLUTION`
(quadint INT64)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (quadint == null) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.getQuadintResolution(quadint);
""";