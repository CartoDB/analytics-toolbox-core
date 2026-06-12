----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__CENTERMEDIAN`
(geojson STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_TRANSFORMATIONS_BUCKET@@"]
)
AS """
    if (!geojson) {
        return null;
    }
    const medianCenter = transformationsLib.centerMedian(transformationsLib.feature(JSON.parse(geojson)));
    return JSON.stringify(medianCenter.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_CENTERMEDIAN`
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(
        `@@BQ_DATASET@@.__CENTERMEDIAN`(
            ST_ASGEOJSON(geog)
        )
    )
);
