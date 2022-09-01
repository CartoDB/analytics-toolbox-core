----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_FROMLONGLAT`
(longitude FLOAT64, latitude FLOAT64, resolution INT64)
RETURNS INT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (longitude == null || latitude == null || resolution == null) {
        throw new Error('NULL argument passed to UDF');
    }
    return coreLib.quadkey.quadintFromLocation(Number(longitude), Number(latitude), Number(resolution)).toString();
""";