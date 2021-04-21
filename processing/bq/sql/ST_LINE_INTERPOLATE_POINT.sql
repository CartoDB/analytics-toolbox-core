-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROCESSING@@.__LINE_INTERPOLATE_POINT`
    (geojson STRING, distance FLOAT64, units STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@PROCESSING_BQ_LIBRARY@@"])
AS """
    if (!geojson || distance == null) {
        return null;
    }
    let options = {};
    if(units)
    {
        options.units = units;
    }
    let along = turf.along(JSON.parse(geojson), distance, options);
    return JSON.stringify(along.geometry);
""";


CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_PROCESSING@@.ST_LINE_INTERPOLATE_POINT`
    (geog GEOGRAPHY, distance FLOAT64, units STRING)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_PROCESSING@@.__LINE_INTERPOLATE_POINT(ST_ASGEOJSON(geog), distance, units))
);