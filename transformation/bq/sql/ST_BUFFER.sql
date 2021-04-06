-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.__BUFFER`(geojson STRING,radius NUMERIC, options STRUCT<unit STRING,steps NUMERIC>)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js 
    OPTIONS (library=["@@TURF_BQ_LIBRARY@@"])
    AS
"""
    var buffer = turf.buffer(JSON.parse(geojson),radius,{'unit':options.unit,'steps':options.steps});
    return JSON.stringify(buffer.geometry);
""";


CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.ST_BUFFER`(geojson GEOGRAPHY, radius NUMERIC, units STRING, steps NUMERIC)
    RETURNS GEOGRAPHY
AS
(
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATION@@.__BUFFER`(ST_ASGEOJSON(geojson),radius,STRUCT(units,steps)))
);

