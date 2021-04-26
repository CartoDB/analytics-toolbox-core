-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.__MINKOWSKIDISTANCE`
    (geojson1 STRING, geojson2 STRING, p FLOAT64)
    RETURNS ARRAY<FLOAT64>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@MEASUREMENTS_BQ_LIBRARY@@"])
AS """
    if (!geojson1 || !geojson2 || p == null) {
        return null;
    }
    let distance = turf.distanceWeight(JSON.parse(geojson1), JSON.parse(geojson2), p);
    return distance;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.ST_MINKOWSKIDISTANCE`
    (geog1 GEOGRAPHY, geog2 GEOGRAPHY, p FLOAT64)
AS (
    `@@BQ_PROJECTID@@`.@@BQ_DATASET_MEASUREMENTS@@.__MINKOWSKIDISTANCE(ST_ASGEOJSON(geog1), ST_ASGEOJSON(geog2), p)
);