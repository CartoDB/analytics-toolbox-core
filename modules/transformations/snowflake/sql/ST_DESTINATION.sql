----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@transformations._DESTINATION
(geojsonStart STRING, distance DOUBLE, bearing DOUBLE, units STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSONSTART || DISTANCE == null || BEARING == null || !UNITS) {
        return null;
    }
    const options = {};
    options.units = UNITS;
    const destination = transformationsLib.destination(JSON.parse(GEOJSONSTART), Number(DISTANCE), Number(BEARING), options);
    return JSON.stringify(destination.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_DESTINATION
(startPoint GEOGRAPHY, distance DOUBLE, bearing DOUBLE)
RETURNS GEOGRAPHY
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@transformations._DESTINATION(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), DISTANCE, BEARING, 'kilometers'))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_DESTINATION
(startPoint GEOGRAPHY, distance DOUBLE, bearing DOUBLE, units STRING)
RETURNS GEOGRAPHY
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@transformations._DESTINATION(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), DISTANCE, BEARING, UNITS))
$$;