-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TURF@@.SIMPLIFY`
    (geojson STRING, options STRUCT<tolerance NUMERIC, highQuality BOOL>)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@TURF_BQ_LIBRARY@@"])
AS """
    var buffer = turf.simplify(JSON.parse(geojson),{'tolerance':options.tolerance,'highQuality':options.highQuality, 'mutate': true});
    return JSON.stringify(buffer);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TURF@@.ST_SIMPLIFY`
    (geojson GEOGRAPHY, tolerance NUMERIC)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TURF@@.SIMPLIFY(ST_ASGEOJSON(geojson), STRUCT(tolerance as tolerance, true as highQuality)))
);
