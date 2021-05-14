----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID
(id STRING) 
RETURNS STRING 
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if(!ID)
    {
        throw new Error('NULL argument passed to UDF');
    }
    
    var cornerLongLat = lib.FromHilbertQuadKey(lib.idToKey(ID)).getCornerLatLngs();
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

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID
(id BIGINT) 
RETURNS STRING
AS $$
    @@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID(CAST(ID AS STRING))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@s2.ST_BOUNDARY
(id BIGINT)
RETURNS GEOGRAPHY
AS $$
    TRY_TO_GEOGRAPHY(@@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID(ID))
$$;