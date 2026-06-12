----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._CONVEXHULL
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_CONVEX@@

    const hull = transformationsConvexLib.convex(JSON.parse(GEOJSON));
    if (hull) {
        return JSON.stringify(hull.geometry);
    }
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CONVEXHULL
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._CONVEXHULL(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;
