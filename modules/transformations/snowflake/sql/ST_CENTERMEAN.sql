----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _CENTERMEAN
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSON) {
        return null;
    }
    const center = transformationsLib.centerMean(JSON.parse(GEOJSON));
    return JSON.stringify(center.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION ST_CENTERMEAN
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(_CENTERMEAN(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;
