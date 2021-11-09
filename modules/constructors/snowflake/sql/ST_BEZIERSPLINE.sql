----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@constructors._BEZIERSPLINE
(geojson STRING, resolution DOUBLE, sharpness DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON || RESOLUTION == null || SHARPNESS == null) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        constructorsLibGlobal = constructorsLib;
    }

    if (typeof(constructorsLibGlobal) === "undefined") {
        setup();
    }

    const options = {};
    options.resolution = Number(RESOLUTION);
    options.sharpness = Number(SHARPNESS);
    const curved = constructorsLibGlobal.bezierSpline(JSON.parse(GEOJSON), options);
    return JSON.stringify(curved.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@constructors.ST_BEZIERSPLINE
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@constructors._BEZIERSPLINE(CAST(ST_ASGEOJSON(GEOG) AS STRING), 10000, 0.85))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@constructors.ST_BEZIERSPLINE
(geog GEOGRAPHY, resolution INT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@constructors._BEZIERSPLINE(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE), 0.85))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@constructors.ST_BEZIERSPLINE
(geog GEOGRAPHY, resolution INT, sharpness DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@constructors._BEZIERSPLINE(CAST(ST_ASGEOJSON(GEOG) AS STRING), CAST(RESOLUTION AS DOUBLE), SHARPNESS))
$$;
