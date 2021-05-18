----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@transformations._CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE, units STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSONS) {
        return null;
    }
    const options = {};
    if (maxEdge != null) {
        options.maxEdge = maxEdge;
    }
    if (units) {
        options.units = units;
    }
    const featuresCollection = transformationsLib.featureCollection(GEOJSONS.map(x => transformationsLib.feature(JSON.parse(x))));
    const hull = transformationsLib.concave(featuresCollection, options);
    return JSON.stringify(hull.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_CONCAVEHULL
(geojsons ARRAY)
RETURNS GEOGRAPHY
AS $$
   TO_GEOGRAPHY(@@SF_PREFIX@@transformations._CONCAVEHULL(GEOJSONS, NULL, NULL))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE)
RETURNS GEOGRAPHY
AS $$
   TO_GEOGRAPHY(@@SF_PREFIX@@transformations._CONCAVEHULL(GEOJSONS, maxEdge, NULL))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE, units STRING)
RETURNS GEOGRAPHY
AS $$
   TO_GEOGRAPHY(@@SF_PREFIX@@transformations._CONCAVEHULL(GEOJSONS, maxEdge, units))
$$;