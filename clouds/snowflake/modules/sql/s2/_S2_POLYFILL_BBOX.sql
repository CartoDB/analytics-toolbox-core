----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._S2_POLYFILL_BBOX
(min_longitude DOUBLE, max_longitude DOUBLE, min_latitude DOUBLE,
 max_latitude DOUBLE, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (MIN_LONGITUDE == null || MAX_LONGITUDE == null || MIN_LATITUDE == null || MAX_LATITUDE == null || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_S2_POLYFILL_BBOX@@
    
    return s2PolyfillBboxLib.polyfillBbox(
        Number(MIN_LONGITUDE),
        Number(MAX_LONGITUDE),
        Number(MIN_LATITUDE),
        Number(MAX_LATITUDE),
        Number(RESOLUTION));
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._S2_POLYFILL_BBOX
(geo GEOGRAPHY, resolution DOUBLE)
RETURNS ARRAY
IMMUTABLE
AS $$
    @@SF_SCHEMA@@._S2_POLYFILL_BBOX(ST_XMIN(GEO), ST_XMAX(GEO), ST_YMIN(GEO), ST_YMIN(GEO), RESOLUTION)
$$;
