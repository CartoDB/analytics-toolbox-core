----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _CENTERMEDIAN
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    @@SF_LIBRARY_CENTER@@

    const medianCenter = transformationsLib.centerMedian(transformationsLib.feature(JSON.parse(GEOJSON)));
    return JSON.stringify(medianCenter.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION ST_CENTERMEDIAN
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(_CENTERMEDIAN(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;