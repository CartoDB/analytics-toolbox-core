----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_MINKOWSKIDISTANCE
(geojsons ARRAY, p DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONS || P == null) {
        return [];
    }

    @@SF_LIBRARY_MEASUREMENTS@@

    const options = {};
    options.p = Number(P);
    const features = measurementsLib.featureCollection(GEOJSONS.map(x => measurementsLib.feature(JSON.parse(x))));
    const distance = measurementsLib.distanceWeight(features, options);
    return distance;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_MINKOWSKIDISTANCE
(geojsons ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@.ST_MINKOWSKIDISTANCE(GEOJSONS, 2)
$$;
