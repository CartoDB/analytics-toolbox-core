----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _BUFFER
(geojson STRING, radius DOUBLE, units STRING, steps DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || RADIUS == null) {
        return null;
    }

    const options = {};
    if (UNITS) {
        options.units = UNITS;
    }
    if (STEPS != null) {
        options.steps = Number(STEPS);
    }

    @@SF_LIBRARY_BUFFER@@

    const buffer = transformationsLib.buffer(JSON.parse(GEOJSON), Number(RADIUS), options);
    if (buffer) {
        return JSON.stringify(buffer.geometry);
    }
$$;

CREATE OR REPLACE SECURE FUNCTION ST_BUFFER
(geog GEOGRAPHY, radius DOUBLE, units STRING, steps DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(_BUFFER(CAST(ST_ASGEOJSON(GEOG) AS STRING), RADIUS, UNITS, STEPS))
$$;
