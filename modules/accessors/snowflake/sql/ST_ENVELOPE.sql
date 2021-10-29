----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@accessors._ENVELOPE
(geojsons ARRAY)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSONS) {
        return null;
    }

    const featuresCollection = accessorsLib.featureCollection(GEOJSONS.map(x => accessorsLib.feature(JSON.parse(x))));
    const enveloped = accessorsLib.envelope(featuresCollection);
    return JSON.stringify(enveloped.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@accessors.ST_ENVELOPE
(geojsons ARRAY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    SELECT TO_GEOGRAPHY(@@SF_PREFIX@@accessors._ENVELOPE(GEOJSONS))
$$;