----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._DISSOLVE
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_DISSOLVE@@
    
    const dissolve = transformationsDissolveLib.cartoDissolve(JSON.parse(GEOJSON));
    if (dissolve) {
        return JSON.stringify(dissolve.geometry);
    }
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_DISSOLVE
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._DISSOLVE(CAST(ST_ASGEOJSON(ST_COLLECT(GEOG)) AS STRING)))
$$;
