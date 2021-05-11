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
    let options = {};
    if(maxEdge != null)
    {
        options.maxEdge = maxEdge;
    }
    if(units)
    {
        options.units = units;
    }
    const featuresCollection = lib.featureCollection(geojson.map(x => lib.feature(JSON.parse(x))));
    var hull = lib.concave(featuresCollection, options);
    return JSON.stringify(hull.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@transformations.ST_CONCAVEHULL`
(geog ARRAY<GEOGRAPHY>, maxEdge FLOAT64, units STRING)
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@transformations.__CONCAVEHULL`(ARRAY_AGG(ST_ASGEOJSON(x)), maxEdge, units)) FROM unnest(geog) x
));