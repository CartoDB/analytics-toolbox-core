-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_ACCESSORS@@.__ENVELOPE`
    (geojson ARRAY<STRING>)
    RETURNS STRING
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@ACCESSORS_BQ_LIBRARY@@"])
AS """
    if (!geojson) {
        return null;
    }

    const featuresCollection = turf.featureCollection(geojson.map(x => turf.feature(JSON.parse(x))));
    var enveloped = turf.envelope(featuresCollection);
    return JSON.stringify(enveloped.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_ACCESSORS@@.ST_ENVELOPE`
    (geog ARRAY<GEOGRAPHY>)
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_ACCESSORS@@.__ENVELOPE(ARRAY_AGG(ST_ASGEOJSON(x)))) FROM unnest(geog) x
));