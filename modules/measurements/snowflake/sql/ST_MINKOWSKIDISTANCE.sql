----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION ST_MINKOWSKIDISTANCE
(geojsons ARRAY, p DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONS || P == null) {
        return [];
    }

    @@SF_LIBRARY_CONTENT@@

    const options = {};
    options.p = Number(P);
    const features = measurementsLib.featureCollection(GEOJSONS.map(x => measurementsLib.feature(JSON.parse(x))));
    const distance = measurementsLib.distanceWeight(features, options);
    return distance;
$$;

CREATE OR REPLACE SECURE FUNCTION ST_MINKOWSKIDISTANCE
(geojsons ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$
    ST_MINKOWSKIDISTANCE(GEOJSONS, 2)
$$;
