-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._GEOJSONBOUNDARY_FROMID
    (id STRING) 
    RETURNS STRING 
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    if(!ID)
    {
        throw new Error('NULL argument passed to UDF');
    }
    
    var cornerLongLat = S2.S2Cell.FromHilbertQuadKey(S2.idToKey(ID)).getCornerLatLngs();
    var geojson = {
        "type": "Polygon",
        "coordinates": [[
        [cornerLongLat[0]['lng'],cornerLongLat[0]['lat']],
        [cornerLongLat[1]['lng'],cornerLongLat[1]['lat']],
        [cornerLongLat[2]['lng'],cornerLongLat[2]['lat']],
        [cornerLongLat[3]['lng'],cornerLongLat[3]['lat']],
        [cornerLongLat[0]['lng'],cornerLongLat[0]['lat']]
        ]]
    };
    return JSON.stringify(geojson);
$$;

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._GEOJSONBOUNDARY_FROMID
    (id BIGINT) 
    RETURNS STRING
AS $$
    @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._GEOJSONBOUNDARY_FROMID(CAST(ID AS STRING))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_S2@@.ST_BOUNDARY
    (id BIGINT)
    RETURNS GEOGRAPHY
AS $$
    TRY_TO_GEOGRAPHY(@@SF_DATABASEID@@.@@SF_SCHEMA_S2@@._GEOJSONBOUNDARY_FROMID(ID))
$$;
