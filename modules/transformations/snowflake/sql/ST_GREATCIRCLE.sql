----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@transformations._GREATCIRCLE
(geojsonStart STRING, geojsonEnd STRING, npoints DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSONSTART || !GEOJSONEND) {
        return null;
    }
    const options = {};
    if (NPOINTS != null) {
        options.npoints = Number(NPOINTS);
    }
    const greatCircle = transformationsLib.greatCircle(JSON.parse(GEOJSONSTART), JSON.parse(GEOJSONEND), options);
    return JSON.stringify(greatCircle.geometry);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_GREATCIRCLE
(startPoint GEOGRAPHY, endPoint GEOGRAPHY)
RETURNS GEOGRAPHY
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@transformations._GREATCIRCLE(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), CAST(ST_ASGEOJSON(ENDPOINT) AS STRING), NULL))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@transformations.ST_GREATCIRCLE
(startPoint GEOGRAPHY, endPoint GEOGRAPHY, npoints INT)
RETURNS GEOGRAPHY
AS $$
    TO_GEOGRAPHY(@@SF_PREFIX@@transformations._GREATCIRCLE(CAST(ST_ASGEOJSON(STARTPOINT) AS STRING), CAST(ST_ASGEOJSON(ENDPOINT) AS STRING), CAST(NPOINTS AS DOUBLE)))
$$;