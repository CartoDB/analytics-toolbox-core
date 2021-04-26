-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CONSTRUCTORS@@.__BEZIERSPLINE`
    (geojson STRING, sharpness FLOAT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@CONSTRUCTORS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }
    let options = {};
    if(sharpness != null)
    {
        options.sharpness = Number(sharpness);
    }
    let curved = turf.bezierSpline(JSON.parse(geojson), options);
    return JSON.stringify(curved.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CONSTRUCTORS@@.ST_BEZIERSPLINE`
    (geog GEOGRAPHY, sharpness FLOAT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_CONSTRUCTORS@@.__BEZIERSPLINE(ST_ASGEOJSON(geog), sharpness))
);
