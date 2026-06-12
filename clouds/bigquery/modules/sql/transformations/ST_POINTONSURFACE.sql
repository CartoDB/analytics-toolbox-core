----------------------------
-- Copyright (C) 2024 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__POINTONSURFACE`
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
    const center = transformationsLib.pointOnFeature(JSON.parse(geojson));
    return JSON.stringify(center.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_POINTONSURFACE`
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(
        `@@BQ_DATASET@@.__POINTONSURFACE`(
            ST_ASGEOJSON(geog)
        )
    )
);
