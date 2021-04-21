-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.__GREATCIRCLE`
    (geojsonStart STRING, geojsonEnd STRING, npoints INT64)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@TRANSFORMATION_BQ_LIBRARY@@"])
AS """
    if (!geojsonStart || !geojsonEnd) {
        return null;
    }
    let options = {};
    if(npoints != null)
    {
        options.npoints = Number(npoints);
    }
    let greatCircle = turf.greatCircle(JSON.parse(geojsonStart), JSON.parse(geojsonEnd), options);
    return JSON.stringify(greatCircle.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.ST_GREATCIRCLE`
    (startPoint GEOGRAPHY, endPoint GEOGRAPHY, npoints INT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TRANSFORMATION@@.__GREATCIRCLE(ST_ASGEOJSON(startPoint), ST_ASGEOJSON(endPoint), npoints))
);