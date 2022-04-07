----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _BUFFER
(geojson STRING, distance DOUBLE, segments DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || DISTANCE == null || SEGMENTS == null) {
        return null;
    }

    @@SF_LIBRARY_BUFFER@@

    const options = {
        units: 'meters',
        steps: Number(SEGMENTS)
    };
    const buffer = transformationsLib.buffer(JSON.parse(GEOJSON), Number(DISTANCE), options);
    if (buffer) {
        return JSON.stringify(buffer.geometry);
    }
$$;

CREATE OR REPLACE SECURE FUNCTION ST_BUFFER
(geog GEOGRAPHY, distance DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(_BUFFER(CAST(ST_ASGEOJSON(GEOG) AS STRING), DISTANCE, 8))
$$;

CREATE OR REPLACE SECURE FUNCTION ST_BUFFER
(geog GEOGRAPHY, distance DOUBLE, segments INTEGER)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(_BUFFER(CAST(ST_ASGEOJSON(GEOG) AS STRING), DISTANCE, TO_DOUBLE(SEGMENTS)))
$$;
