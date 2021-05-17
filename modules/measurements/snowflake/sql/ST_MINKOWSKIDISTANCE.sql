----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements._MINKOWSKIDISTANCE
(geojson STRING, p DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSON) {
        return null;
    }
    const options = {};
    if(P != null) {
        options.p = Number(P);
    }
    const features = measurementsLib.featureCollection(JSON.parse(GEOJSON));
    return JSON.stringify(features);
    const distance = measurementsLib.distanceWeight(features, options);
    return distance;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE
(geog GEOGRAPHY, p DOUBLE)
RETURNS STRING
AS $$
    @@SF_PREFIX@@measurements._MINKOWSKIDISTANCE(CAST(ST_ASGEOJSON(GEOG) AS STRING), P)
$$;