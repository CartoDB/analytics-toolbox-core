----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__MINKOWSKIDISTANCE`
(geojson ARRAY<STRING>, p FLOAT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_MEASUREMENTS_BUCKET@@"]
)
AS """
    if (!geojson) {
        return null;
    }
    const options = {};
    if(p != null) {
        options.p = Number(p);
    }
    const features = measurementsLib.featureCollection(geojson.map(x => measurementsLib.feature(JSON.parse(x))));
    const distance = measurementsLib.distanceWeight(features, options);
    return distance;
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_MINKOWSKIDISTANCE`
(geog ARRAY<GEOGRAPHY>, p FLOAT64)
RETURNS ARRAY<STRING>
AS ((
    SELECT `@@BQ_DATASET@@.__MINKOWSKIDISTANCE`(ARRAY_AGG(ST_ASGEOJSON(x)), p)
    FROM UNNEST(geog) AS x
));
