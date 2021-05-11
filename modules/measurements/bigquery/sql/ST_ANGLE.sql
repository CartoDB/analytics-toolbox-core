----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@measurements.__ANGLE`
(geojsonStart STRING, geojsonMid STRING, geojsonEnd STRING, mercator BOOLEAN)
RETURNS FLOAT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojsonStart || !geojsonMid || !geojsonEnd) {
        return null;
    }
    let options = {};
    if(mercator != null)
    {
        options.mercator = mercator;
    }
    return lib.angle(JSON.parse(geojsonStart), JSON.parse(geojsonMid), JSON.parse(geojsonEnd), options);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@measurements.ST_ANGLE`
    (startPoint GEOGRAPHY, midPoint GEOGRAPHY, endPoint GEOGRAPHY, mercator BOOLEAN)
AS (
    `@@BQ_PREFIX@@measurements.__ANGLE`(ST_ASGEOJSON(startPoint), ST_ASGEOJSON(midPoint), ST_ASGEOJSON(endPoint), mercator)
);
