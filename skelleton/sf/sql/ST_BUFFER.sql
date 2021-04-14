-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_SQUELLETON@@._BUFFER
    (geojson STRING, radius DOUBLE, unit STRING, steps DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@

    if (!GEOJSON || RADIUS == null || !UNIT || STEPS == null) {
        return null;
    }
    var buffer = turf.buffer(JSON.parse(GEOJSON), Number(RADIUS),{'unit': UNIT, 'steps': Number(STEPS)});
    return JSON.stringify(buffer.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_SQUELLETON@@.ST_BUFFER
    (geog GEOGRAPHY, radius DOUBLE, units STRING, steps INT)
    RETURNS GEOGRAPHY
AS $$
    TRY_TO_GEOGRAPHY(@@SF_DATABASEID@@.@@SF_SCHEMA_SQUELLETON@@._BUFFER(CAST(ST_ASGEOJSON(GEOG) AS STRING), RADIUS, UNITS, CAST(STEPS AS DOUBLE)))
$$;