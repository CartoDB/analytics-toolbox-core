----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE
(geojsons ARRAY, p DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!GEOJSONS || P == null) {
        return [];
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        measurementsLibGlobal = measurementsLib;
    }

    if (typeof(measurementsLibGlobal) === "undefined") {
        setup();
    }

    const options = {};
    options.p = Number(P);
    const features = measurementsLibGlobal.featureCollection(GEOJSONS.map(x => measurementsLibGlobal.feature(JSON.parse(x))));
    const distance = measurementsLibGlobal.distanceWeight(features, options);
    return distance;
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE
(geojsons ARRAY)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_PREFIX@@measurements.ST_MINKOWSKIDISTANCE(GEOJSONS, 2)
$$;
