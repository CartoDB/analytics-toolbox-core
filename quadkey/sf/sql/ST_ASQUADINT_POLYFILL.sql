-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._POLYFILL_FROMGEOJSON
    (geojson STRING, resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    if(!GEOJSON || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    let pol = JSON.parse(GEOJSON);
    let quadints = geojsonToQuadints(pol, {min_zoom: RESOLUTION, max_zoom: RESOLUTION});
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.ST_ASQUADINT_POLYFILL
    (geo GEOGRAPHY, resolution INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@._POLYFILL_FROMGEOJSON(CAST(ST_ASGEOJSON(GEO) AS STRING),CAST(RESOLUTION AS DOUBLE))
$$;