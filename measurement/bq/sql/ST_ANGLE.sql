-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENT@@.__ANGLE`
    (geojsonStart STRING, geojsonMid STRING, geojsonEnd STRING, mercator BOOLEAN)
    RETURNS FLOAT64
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@MEASUREMENT_BQ_LIBRARY@@"])
AS """
    if (!geojsonStart || !geojsonMid || !geojsonEnd) {
        return null;
    }
    let options = {};
    if(mercator != null)
    {
        options.mercator = mercator;
    }
    return turf.angle(JSON.parse(geojsonStart), JSON.parse(geojsonMid), JSON.parse(geojsonEnd), options);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENT@@.ST_ANGLE`
    (startPoint GEOGRAPHY, midPoint GEOGRAPHY, endPoint GEOGRAPHY, mercator BOOLEAN)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_MEASUREMENT@@.__ANGLE(ST_ASGEOJSON(startPoint), ST_ASGEOJSON(midPoint), ST_ASGEOJSON(endPoint), mercator)
);