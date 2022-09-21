----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__CENTERMEAN`
(geojson STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_BUCKET@@"]
)
AS """
    if (!geojson) {
        return null;
    }
    const center = lib.transformations.centerMean(JSON.parse(geojson));
    return JSON.stringify(center.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_CENTERMEAN`
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(
        `@@BQ_DATASET@@.__CENTERMEAN`(
            ST_ASGEOJSON(geog)
        )
    )
);
