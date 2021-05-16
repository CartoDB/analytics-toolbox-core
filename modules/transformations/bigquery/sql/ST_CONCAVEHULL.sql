----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.__CONCAVEHULL`
(geojson ARRAY<STRING>, maxEdge FLOAT64, units STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (!geojson) {
        return null;
    }
    const options = {};
    if (maxEdge != null) {
        options.maxEdge = maxEdge;
    }
    if (units) {
        options.units = units;
    }
    const featuresCollection = transformationsLib.featureCollection(geojson.map(x => transformationsLib.feature(JSON.parse(x))));
    const hull = transformationsLib.concave(featuresCollection, options);
    return JSON.stringify(hull.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.ST_CONCAVEHULL`
(geog ARRAY<GEOGRAPHY>, maxEdge FLOAT64, units STRING)
RETURNS GEOGRAPHY
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@transformations.__CONCAVEHULL`(ARRAY_AGG(ST_ASGEOJSON(x)), maxEdge, units)) FROM unnest(geog) x
));