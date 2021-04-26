-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.__MINKOWSKIDISTANCE`
    (geojson STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@MEASUREMENTS_BQ_LIBRARY@@"])
AS """
    return null;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.ST_MINKOWSKIDISTANCE`
    (geog GEOGRAPHY)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_MEASUREMENTS@@.__MINKOWSKIDISTANCE(ST_ASGEOJSON(geog)))
);