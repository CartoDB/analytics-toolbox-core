----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE or REPLACE FUNCTION @@SF_SCHEMA@@._ENVELOPE_ARR
(geojsons ARRAY)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONS) {
        return null;
    }

    @@SF_LIBRARY_ACCESSORS@@

    const featuresCollection = accessorsLib.featureCollection(GEOJSONS.map(x => accessorsLib.feature(JSON.parse(x))));
    const enveloped = accessorsLib.envelope(featuresCollection);
    return JSON.stringify(enveloped.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_ENVELOPE_ARR
(geojsons ARRAY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    SELECT TO_GEOGRAPHY(@@SF_SCHEMA@@._ENVELOPE_ARR(GEOJSONS))
$$;
