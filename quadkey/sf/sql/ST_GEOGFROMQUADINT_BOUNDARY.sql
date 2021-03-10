-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.GEOJSONBOUNDARY_FROMQUADINT
    (quadint DOUBLE)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@WASM_FILE_CONTENTS@@
    
    if(QUADINT == null)
    {
        throw new Error('NULL argument passed to UDF');
    }

    let geojson = quadintToGeoJSON(QUADINT);
    return JSON.stringify(geojson);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.GEOJSONBOUNDARY_FROMQUADINT
    (quadint INT)
    RETURNS STRING
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.GEOJSONBOUNDARY_FROMQUADINT(CAST(QUADINT AS DOUBLE))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.ST_GEOGFROMQUADINT_BOUNDARY
    (quadint INT)
    RETURNS GEOGRAPHY
AS $$
    TO_GEOGRAPHY(@@SF_DATABASEID@@.@@SF_SCHEMA_QUADKEY@@.GEOJSONBOUNDARY_FROMQUADINT(QUADINT))
$$;