----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@measurements.__AZIMUTH`
(geojsonStart STRING, geojsonEnd STRING)
RETURNS FLOAT64
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojsonStart || !geojsonEnd) {
        return null;
    }
    return measurementsLib.bearing(JSON.parse(geojsonStart), JSON.parse(geojsonEnd));
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@measurements.ST_AZIMUTH`
(startPoint GEOGRAPHY, endPoint GEOGRAPHY)
RETURNS FLOAT64
AS (
    `@@BQ_PREFIX@@measurements.__AZIMUTH`(ST_ASGEOJSON(startPoint), ST_ASGEOJSON(endPoint))
);