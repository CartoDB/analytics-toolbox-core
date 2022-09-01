----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_TOCHILDREN`
(quadint INT64, resolution INT64)
RETURNS ARRAY<INT64>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (quadint == null || resolution == null) {
        throw new Error('NULL argument passed to UDF');
    }
    const quadints = coreLib.quadkey.toChildren(quadint, Number(resolution));
    return quadints.map(String);
""";