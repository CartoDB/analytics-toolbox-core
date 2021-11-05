----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _ENVELOPE_ARR
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

CREATE OR REPLACE SECURE FUNCTION ST_ENVELOPE_ARR
(geojsons ARRAY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    SELECT TO_GEOGRAPHY(_ENVELOPE_ARR(GEOJSONS))
$$;