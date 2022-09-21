----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_FROMLONGLAT`
(longitude FLOAT64, latitude FLOAT64, resolution INT64)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_BUCKET@@"]
)
AS """
    if (latitude == null || longitude == null || resolution == null) {
        throw new Error('NULL argument passed to UDF');
    }
    const key = lib.s2.latLngToKey(Number(latitude), Number(longitude), Number(resolution));
    return lib.s2.keyToId(key);
""";
