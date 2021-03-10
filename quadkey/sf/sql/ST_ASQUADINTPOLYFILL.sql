-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.POLYFILL_FROMGEOJSON
    (geojson STRING, resolution DOUBLE)
    RETURNS ARRAY
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@
    
    if(!GEOJSON || RESOLUTION == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    let pol = JSON.parse(GEOJSON);
    return geojsonToQuadints(pol, {min_zoom: RESOLUTION, max_zoom: RESOLUTION});
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.POLYFILL_FROMGEOJSON
    (geojson STRING, resolution INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.POLYFILL_FROMGEOJSON(GEOJSON,CAST(RESOLUTION AS DOUBLE))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.ST_ASQUADINTPOLYFILL
    (geo GEOGRAPHY, resolution INT)
    RETURNS ARRAY
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.POLYFILL_FROMGEOJSON(CAST(ST_ASGEOJSON(GEO) AS STRING),RESOLUTION)
$$;