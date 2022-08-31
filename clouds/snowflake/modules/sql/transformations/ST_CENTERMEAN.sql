----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._CENTERMEAN
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_CENTER@@

    const center = transformationsCenterLib.centerMean(JSON.parse(GEOJSON));
    return JSON.stringify(center.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CENTERMEAN
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._CENTERMEAN(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;