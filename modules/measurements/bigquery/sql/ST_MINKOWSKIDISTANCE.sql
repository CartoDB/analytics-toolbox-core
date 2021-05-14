----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@measurements.__MINKOWSKIDISTANCE`
(geojson ARRAY<STRING>, p FLOAT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }
    const options = {};
    if(p != null) {
        options.p = Number(p);
    }
    const features = lib.featureCollection(geojson.map(x => lib.feature(JSON.parse(x))));
    const distance = lib.distanceWeight(features, options);
    return distance;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@measurements.ST_MINKOWSKIDISTANCE`
(geog ARRAY<GEOGRAPHY>, p FLOAT64)
RETURNS ARRAY<STRING>
AS ((
    SELECT `@@BQ_PREFIX@@measurements.__MINKOWSKIDISTANCE`(ARRAY_AGG(ST_ASGEOJSON(x)), p)
    FROM unnest(geog) x
));