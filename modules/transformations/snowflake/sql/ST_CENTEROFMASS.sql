----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@transformations._CENTEROFMASS
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

    const center = transformationsLibGlobal.centerOfMass(JSON.parse(GEOJSON));
    return JSON.stringify(center.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_CENTEROFMASS
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@transformations._CENTEROFMASS(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;