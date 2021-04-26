-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.__CENTERMEAN`
    (geojson STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@MEASUREMENTS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }
    var center = turf.centerMean(JSON.parse(geojson));
    return JSON.stringify(center.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.ST_CENTERMEAN`
    (geog GEOGRAPHY)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_MEASUREMENTS@@.__CENTERMEAN(ST_ASGEOJSON(geog)))
);
