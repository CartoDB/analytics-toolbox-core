-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.__MINKOWSKIDISTANCE`
    (geojson ARRAY<STRING>, p FLOAT64)
    RETURNS ARRAY<STRING>
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@MEASUREMENTS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }
    let options = {};
    if(p != null)
    {
        options.p = Number(p);
    }
    const features = turf.featureCollection(geojson.map(x => turf.feature(JSON.parse(x))));
    let distance = turf.distanceWeight(features, options);
    return distance;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_MEASUREMENTS@@.ST_MINKOWSKIDISTANCE`
    (geog ARRAY<GEOGRAPHY>, p FLOAT64)
AS ((
    SELECT `@@BQ_PROJECTID@@`.@@BQ_DATASET_MEASUREMENTS@@.__MINKOWSKIDISTANCE(ARRAY_AGG(ST_ASGEOJSON(x)), p) FROM unnest(geog) x
));