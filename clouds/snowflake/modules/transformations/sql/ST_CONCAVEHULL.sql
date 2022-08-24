----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE, units STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONS || MAXEDGE == null || !UNITS) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_CONCAVE@@

    const multiPoints = transformations_concaveLib.multiPoint(GEOJSONS.map(x => JSON.parse(x).coordinates));
    const nonDuplicates = transformations_concaveLib.cleanCoords(multiPoints).geometry;
    const arrayCoordinates = nonDuplicates.coordinates;

    // Point
    if (arrayCoordinates.length == 1) {
        return JSON.stringify(transformations_concaveLib.point(arrayCoordinates[0]).geometry);
    }

    // Segment
    if (arrayCoordinates.length == 2) {
        const start = arrayCoordinates[0];
        const end = arrayCoordinates[1];
        const lineString = transformations_concaveLib.lineString([start, end]);
        return JSON.stringify(lineString.geometry);
    }

    const options = {};
    options.maxEdge = MAXEDGE;
    options.units = UNITS;
    const featuresCollection = transformations_concaveLib.featureCollection(arrayCoordinates.map(x => transformations_concaveLib.point(x)));
    const hull = transformations_concaveLib.concave(featuresCollection, options);
    return JSON.stringify(hull.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CONCAVEHULL
(geojsons ARRAY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
   TO_GEOGRAPHY(@@SF_SCHEMA@@._CONCAVEHULL(GEOJSONS, CAST('inf' AS DOUBLE), 'kilometers'))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
   TO_GEOGRAPHY(@@SF_SCHEMA@@._CONCAVEHULL(GEOJSONS, MAXEDGE, 'kilometers'))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE, units STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
   TO_GEOGRAPHY(@@SF_SCHEMA@@._CONCAVEHULL(GEOJSONS, MAXEDGE, UNITS))
$$;