----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._GREATCIRCLE
(geojsonStart STRING, geojsonEnd STRING, npoints DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONSTART || !GEOJSONEND || NPOINTS == null || GEOJSONSTART === GEOJSONEND) {
        return null;
    }

    @@SF_LIBRARY_TRANSFORMATIONS_GREATCIRCLE@@

    const options = {};
    options.npoints = Number(NPOINTS);
    const greatCircle = transformationsGreatcircleLib.greatCircle(JSON.parse(GEOJSONSTART), JSON.parse(GEOJSONEND), options);
    return JSON.stringify(greatCircle.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_GREATCIRCLE
(startPoint GEOGRAPHY, endPoint GEOGRAPHY)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._GREATCIRCLE(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), CAST(ST_ASGEOJSON(ENDPOINT) AS STRING), 100))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_GREATCIRCLE
(startPoint GEOGRAPHY, endPoint GEOGRAPHY, npoints INT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(@@SF_SCHEMA@@._GREATCIRCLE(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), CAST(ST_ASGEOJSON(ENDPOINT) AS STRING), CAST(NPOINTS AS DOUBLE)))
$$;
