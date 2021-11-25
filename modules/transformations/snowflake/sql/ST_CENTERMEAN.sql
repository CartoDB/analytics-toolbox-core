----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __CENTERMEAN
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    @@SF_LIBRARY_CONTENT@@

    const center = transformationsLib.centerMean(JSON.parse(GEOJSON));
    return JSON.stringify(center.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION ST_CENTERMEAN
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(__CENTERMEAN(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;
