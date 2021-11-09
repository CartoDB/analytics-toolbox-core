----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@measurements._AZIMUTH
(geojsonStart STRING, geojsonEnd STRING)
RETURNS DOUBLE
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONSTART || !GEOJSONEND) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        measurementsLibGlobal = measurementsLib;
    }

    if (typeof(measurementsLibGlobal) === "undefined") {
        setup();
    }

    return measurementsLibGlobal.bearing(JSON.parse(GEOJSONSTART), JSON.parse(GEOJSONEND));
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.ST_AZIMUTH
(startPoint GEOGRAPHY, endPoint GEOGRAPHY)
RETURNS DOUBLE
IMMUTABLE
AS $$
    @@SF_PREFIX@@measurements._AZIMUTH(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), CAST(ST_ASGEOJSON(ENDPOINT) AS STRING))
$$;
