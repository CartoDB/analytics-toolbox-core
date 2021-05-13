----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@quadkey._POLYFILL_FROMGEOJSON
(geojson STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if(!GEOJSON || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    let pol = JSON.parse(GEOJSON);
    let quadints = lib.geojsonToQuadints(pol, {min_zoom: RESOLUTION, max_zoom: RESOLUTION});
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.ST_ASQUADINT_POLYFILL
(geo GEOGRAPHY, resolution INT)
RETURNS ARRAY
AS $$
    @@SF_PREFIX@@quadkey._POLYFILL_FROMGEOJSON(CAST(ST_ASGEOJSON(GEO) AS STRING),CAST(RESOLUTION AS DOUBLE))
$$;