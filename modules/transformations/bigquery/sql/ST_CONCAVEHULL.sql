----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__CONCAVEHULL`
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

    const multiPoints = transformationsLib.multiPoint(geojson.map(x => JSON.parse(x).coordinates));
    const nonDuplicates = transformationsLib.cleanCoords(multiPoints).geometry;
    const arrayCoordinates = nonDuplicates.coordinates;

    // Point
    if (arrayCoordinates.length == 1) {
        return JSON.stringify(transformationsLib.point(arrayCoordinates[0]).geometry);
    } 

    // Segment
    if (arrayCoordinates.length == 2) {
        const start = arrayCoordinates[0];
        const end = arrayCoordinates[1];
        const lineString = transformationsLib.lineString([start, end]);
        return JSON.stringify(lineString.geometry);
    }

    const featuresCollection = transformationsLib.featureCollection(arrayCoordinates.map(x => transformationsLib.point(x)));
    const hull = transformationsLib.concave(featuresCollection, options);
    return JSON.stringify(hull.geometry);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.ST_CONCAVEHULL`
(geog ARRAY<GEOGRAPHY>, maxEdge FLOAT64, units STRING)
RETURNS GEOGRAPHY
AS ((
    SELECT ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@carto.__CONCAVEHULL`(ARRAY_AGG(ST_ASGEOJSON(x)), maxEdge, units)) FROM unnest(geog) x
));
