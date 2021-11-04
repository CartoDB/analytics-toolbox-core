----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE, units STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSONS || MAXEDGE == null || !UNITS) {
        return null;
    }
    const options = {};
    options.maxEdge = MAXEDGE;
    options.units = UNITS;
    const featuresCollection = transformationsLib.featureCollection(GEOJSONS.map(x => transformationsLib.feature(JSON.parse(x))));
    const hull = transformationsLib.concave(featuresCollection, options);
    return JSON.stringify(hull.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION ST_CONCAVEHULL
(geojsons ARRAY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
   TO_GEOGRAPHY(_CONCAVEHULL(GEOJSONS, CAST('inf' AS DOUBLE), 'kilometers'))
$$;

CREATE OR REPLACE SECURE FUNCTION ST_CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
   TO_GEOGRAPHY(_CONCAVEHULL(GEOJSONS, MAXEDGE, 'kilometers'))
$$;

CREATE OR REPLACE SECURE FUNCTION ST_CONCAVEHULL
(geojsons ARRAY, maxEdge DOUBLE, units STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
   TO_GEOGRAPHY(_CONCAVEHULL(GEOJSONS, MAXEDGE, UNITS))
$$;