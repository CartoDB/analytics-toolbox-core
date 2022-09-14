----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__DESTINATION`
(geojsonStart STRING, distance FLOAT64, bearing FLOAT64, units STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojsonStart || distance == null || bearing == null) {
        return null;
    }
    const options = {};
    if (units) {
        options.units = units;
    }
    const destination = lib.transformations.destination(JSON.parse(geojsonStart), Number(distance), Number(bearing), options);
    return JSON.stringify(destination.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_DESTINATION`
(startPoint GEOGRAPHY, distance FLOAT64, bearing FLOAT64, units STRING)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_DATASET@@.__DESTINATION`(ST_ASGEOJSON(startPoint), distance, bearing, units))
);