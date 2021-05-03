-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATIONS@@.__CONCAVEHULL`
    (geojson ARRAY<STRING>)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@TRANSFORMATIONS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }

    const featuresCollection = turf.featureCollection(geojson.map(x => turf.feature(JSON.parse(x))));
    var hull = turf.concave(featuresCollection);
    return JSON.stringify(hull.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_TRANSFORMATIONS@@.ST_CONCAVEHULL`
    (geog ARRAY<GEOGRAPHY>)
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_TRANSFORMATIONS@@.__CONCAVEHULL(ARRAY_AGG(ST_ASGEOJSON(x)))) FROM unnest(geog) x
));