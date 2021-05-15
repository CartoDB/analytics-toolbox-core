----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@accessors.__ENVELOPE`
(geojson ARRAY<STRING>)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }

    const featuresCollection = lib.featureCollection(geojson.map(x => lib.feature(JSON.parse(x))));
    const enveloped = lib.envelope(featuresCollection);
    return JSON.stringify(enveloped.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@accessors.ST_ENVELOPE`
(geog ARRAY<GEOGRAPHY>)
RETURNS GEOGRAPHY
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@accessors.__ENVELOPE`(ARRAY_AGG(ST_ASGEOJSON(x)))) FROM UNNEST(geog) x
));