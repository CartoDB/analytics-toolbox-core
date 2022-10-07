----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._BBOX_FROM_GEOJSON
(geojson STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_RANDOM@@

    return randomLib.bbox(JSON.parse(GEOJSON));
$$;
