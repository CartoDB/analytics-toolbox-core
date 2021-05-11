----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@constructors.__BEZIERSPLINE`
(geojson STRING, resolution INT64, sharpness FLOAT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }
    let options = {};
    if(resolution != null)
    {
        options.resolution = Number(resolution);
    }
    if(sharpness != null)
    {
        options.sharpness = Number(sharpness);
    }
    const curved = lib.bezierSpline(JSON.parse(geojson), options);
    return JSON.stringify(curved.geometry);
""";
