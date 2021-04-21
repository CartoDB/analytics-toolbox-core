-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.__DESTINATION`
    (geojsonStart STRING, distance FLOAT64, bearing FLOAT64, units STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@TRANSFORMATION_BQ_LIBRARY@@"])
AS """
    if (!geojsonStart || distance == null || bearing == null) {
        return null;
    }
    let options = {};
    if(units)
    {
        options.units = units;
    }
    var destination = turf.destination(JSON.parse(geojsonStart), Number(distance), Number(bearing), options);
    return JSON.stringify(destination.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.ST_DESTINATION`
    (startPoint GEOGRAPHY, distance FLOAT64, bearing FLOAT64, units STRING)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TRANSFORMATION@@.__DESTINATION(ST_ASGEOJSON(startPoint), distance, bearing, units))
);