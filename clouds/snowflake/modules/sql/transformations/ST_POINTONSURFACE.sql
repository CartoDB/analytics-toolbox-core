----------------------------
-- Copyright (C) 2024 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._POINTONSURFACE
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_CENTER@@

    const center = transformationsCenterLib.pointOnSurface(JSON.parse(GEOJSON));
    return JSON.stringify(center.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_POINTONSURFACE
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._POINTONSURFACE(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;
