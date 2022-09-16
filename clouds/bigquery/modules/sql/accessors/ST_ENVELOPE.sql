----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE or REPLACE FUNCTION `@@BQ_DATASET@@.__ENVELOPE`
(geojson ARRAY<STRING>)
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

    const featuresCollection = lib.accessors.featureCollection(geojson.map(x => lib.accessors.feature(JSON.parse(x))));
    const enveloped = lib.accessors.envelope(featuresCollection);
    return JSON.stringify(enveloped.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_ENVELOPE`
(geog ARRAY<GEOGRAPHY>)
RETURNS GEOGRAPHY
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_DATASET@@.__ENVELOPE`(ARRAY_AGG(ST_ASGEOJSON(x))))
    FROM UNNEST(geog) AS x
));
