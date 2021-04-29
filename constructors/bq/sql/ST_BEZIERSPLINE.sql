-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CONSTRUCTORS@@.__BEZIERSPLINE`
    (geojson STRING, resolution INT64, sharpness FLOAT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@CONSTRUCTORS_BQ_LIBRARY@@"])
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
    let curved = turf.bezierSpline(JSON.parse(geojson), options);
    return JSON.stringify(curved.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_CONSTRUCTORS@@.ST_BEZIERSPLINE`
    (geog GEOGRAPHY, resolution INT64, sharpness FLOAT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_CONSTRUCTORS@@.__BEZIERSPLINE(ST_ASGEOJSON(geog), resolution, sharpness))
);
