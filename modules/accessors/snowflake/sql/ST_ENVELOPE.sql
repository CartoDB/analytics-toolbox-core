----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@accessors._ENVELOPE
(geojsons ARRAY)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONS) {
        return null;
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        accessorsLibGlobal = accessorsLib;
    }

    if (typeof(accessorsLibGlobal) === "undefined") {
        setup();
    }

    const featuresCollection = accessorsLibGlobal.featureCollection(GEOJSONS.map(x => accessorsLibGlobal.feature(JSON.parse(x))));
    const enveloped = accessorsLibGlobal.envelope(featuresCollection);
    return JSON.stringify(enveloped.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@accessors.ST_ENVELOPE
(geojsons ARRAY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    SELECT TO_GEOGRAPHY(@@SF_PREFIX@@accessors._ENVELOPE(GEOJSONS))
$$;