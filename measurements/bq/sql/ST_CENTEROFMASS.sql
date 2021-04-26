-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.__CENTEROFMASS`
    (geojson STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@MEASUREMENTS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }
    var center = turf.centerOfMass(JSON.parse(geojson));
    return JSON.stringify(center.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.ST_CENTEROFMASS`
    (geog GEOGRAPHY)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_MEASUREMENTS@@.__CENTEROFMASS(ST_ASGEOJSON(geog)))
);