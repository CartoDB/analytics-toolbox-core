----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._CENTERMEDIAN
(geojson STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSON) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_CENTER@@

    const medianCenter = transformationsCenterLib.centerMedian(transformationsCenterLib.feature(JSON.parse(GEOJSON)));
    return JSON.stringify(medianCenter.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_CENTERMEDIAN
(geog GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._CENTERMEDIAN(CAST(ST_ASGEOJSON(GEOG) AS STRING)))
$$;
