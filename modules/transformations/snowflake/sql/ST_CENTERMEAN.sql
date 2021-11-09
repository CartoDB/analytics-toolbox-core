----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@transformations._CENTERMEAN
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        transformationsLibGlobal = transformationsLib;
    }

    if (typeof(transformationsLibGlobal) === "undefined") {
        setup();
    }

    const center = transformationsLibGlobal.centerMean(JSON.parse(GEOJSON));
    return JSON.stringify(center.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_CENTERMEAN
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@transformations._CENTERMEAN(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;
