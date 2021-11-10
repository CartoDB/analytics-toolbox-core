----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@measurements._ANGLE
(geojsonStart STRING, geojsonMid STRING, geojsonEnd STRING, mercator BOOLEAN)
RETURNS DOUBLE
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONSTART || !GEOJSONMID || !GEOJSONEND) {
        return null;
    }

    @@SF_LIBRARY_CONTENT@@

    const options = {};
    if(MERCATOR != null) {
        options.mercator = MERCATOR;
    }
    return measurementsLib.angle(JSON.parse(GEOJSONSTART), JSON.parse(GEOJSONMID), JSON.parse(GEOJSONEND), options);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.ST_ANGLE
(startPoint GEOGRAPHY, midPoint GEOGRAPHY, endPoint GEOGRAPHY)
RETURNS DOUBLE
IMMUTABLE
AS $$
    @@SF_PREFIX@@measurements._ANGLE(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), CAST(ST_ASGEOJSON(MIDPOINT) AS STRING), CAST(ST_ASGEOJSON(ENDPOINT) AS STRING), false)
$$;
