----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE
(geojsons ARRAY, p DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!GEOJSONS) {
        return [];
    }
    const options = {};
    if(P != null) {
        options.p = Number(P);
    }
    const features = measurementsLib.featureCollection(GEOJSONS.map(x => measurementsLib.feature(JSON.parse(x))));
    const distance = measurementsLib.distanceWeight(features, options);
    return distance;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE
(geojsons ARRAY)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(GEOJSONS, NULL)
$$;
