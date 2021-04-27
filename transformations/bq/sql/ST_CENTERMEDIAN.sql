-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATIONS@@.__CENTERMEDIAN`
    (geojson STRING)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@TRANSFORMATIONS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }
    let medianCenter = turf.centerMedian(turf.feature(JSON.parse(geojson)));
    return JSON.stringify(medianCenter.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATIONS@@.ST_CENTERMEDIAN`
    (geog GEOGRAPHY)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TRANSFORMATIONS@@.__CENTERMEDIAN(ST_ASGEOJSON(geog)))
);