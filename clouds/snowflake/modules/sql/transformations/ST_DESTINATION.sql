----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._DESTINATION
(geojsonStart STRING, distance DOUBLE, bearing DOUBLE, units STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONSTART || DISTANCE == null || BEARING == null || !UNITS) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_DESTINATION@@

    const options = {};
    options.units = UNITS;
    const destination = transformationsDestinationLib.destination(JSON.parse(GEOJSONSTART), Number(DISTANCE), Number(BEARING), options);
    return JSON.stringify(destination.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_DESTINATION
(startPoint GEOGRAPHY, distance DOUBLE, bearing DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._DESTINATION(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), DISTANCE, BEARING, 'kilometers'))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_DESTINATION
(startPoint GEOGRAPHY, distance DOUBLE, bearing DOUBLE, units STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._DESTINATION(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), DISTANCE, BEARING, UNITS))
$$;
