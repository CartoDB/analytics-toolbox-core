----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._DISSOLVE
(geojson STRING, distance DOUBLE, segments DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || DISTANCE == null || SEGMENTS == null) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_DISSOLVE@@

    const options = {
        units: 'meters',
        steps: Number(SEGMENTS)
    };
    const dissolve = transformationsDissolveLib.dissolve(JSON.parse(GEOJSON), Number(DISTANCE), options);
    if (dissolve) {
        return JSON.stringify(dissolve.geometry);
    }
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_DISSOLVE
(geog GEOGRAPHY, distance DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._DISSOLVE(CAST(ST_ASGEOJSON(GEOG) AS STRING), DISTANCE, 8))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_DISSOLVE
(geog GEOGRAPHY, distance DOUBLE, segments INTEGER)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._DISSOLVE(CAST(ST_ASGEOJSON(GEOG) AS STRING), DISTANCE, TO_DOUBLE(SEGMENTS)))
$$;
