----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__ANGLE`
(geojsonStart STRING, geojsonMid STRING, geojsonEnd STRING, mercator BOOLEAN)
RETURNS FLOAT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojsonStart || !geojsonMid || !geojsonEnd) {
        return null;
    }
    const options = {};
    if(mercator != null) {
        options.mercator = mercator;
    }
    return measurementsLib.angle(JSON.parse(geojsonStart), JSON.parse(geojsonMid), JSON.parse(geojsonEnd), options);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.ST_ANGLE`
(startPoint GEOGRAPHY, midPoint GEOGRAPHY, endPoint GEOGRAPHY, mercator BOOLEAN)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@carto.__ANGLE`(ST_ASGEOJSON(startPoint), ST_ASGEOJSON(midPoint), ST_ASGEOJSON(endPoint), mercator)
);