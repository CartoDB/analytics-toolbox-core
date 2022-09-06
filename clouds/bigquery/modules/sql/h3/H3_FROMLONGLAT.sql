----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.H3_FROMLONGLAT`
(longitude FLOAT64, latitude FLOAT64, resolution INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (longitude === null || latitude === null || resolution === null) {
        return null;
    }
    return lib.h3.geoToH3(Number(latitude), Number(longitude), Number(resolution));
""";