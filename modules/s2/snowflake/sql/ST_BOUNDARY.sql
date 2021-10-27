----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _GEOJSONBOUNDARY_FROMID
(id STRING) 
RETURNS STRING 
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    if (!ID) {
        throw new Error('NULL argument passed to UDF');
    }
    
    const cornerLongLat = s2Lib.FromHilbertQuadKey(s2Lib.idToKey(ID)).getCornerLatLngs();
    const wkt = `POLYGON((` +
        cornerLongLat[0]['lng'] + ` ` + cornerLongLat[0]['lat'] + `, ` +
        cornerLongLat[1]['lng'] + ` ` + cornerLongLat[1]['lat'] + `, ` +
        cornerLongLat[2]['lng'] + ` ` + cornerLongLat[2]['lat'] + `, ` +
        cornerLongLat[3]['lng'] + ` ` + cornerLongLat[3]['lat'] + `, ` +
        cornerLongLat[0]['lng'] + ` ` + cornerLongLat[0]['lat'] +
        `))`;
    return wkt;
$$;

CREATE OR REPLACE FUNCTION _GEOJSONBOUNDARY_FROMID
(id BIGINT) 
RETURNS STRING
AS $$
    _GEOJSONBOUNDARY_FROMID(CAST(ID AS STRING))
$$;

CREATE OR REPLACE SECURE FUNCTION ST_BOUNDARY
(id BIGINT)
RETURNS GEOGRAPHY
AS $$
    TRY_TO_GEOGRAPHY(_GEOJSONBOUNDARY_FROMID(ID))
$$;