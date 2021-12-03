----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _S2_BOUNDARY
(id STRING) 
RETURNS STRING 
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!ID) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

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

CREATE OR REPLACE FUNCTION _S2_BOUNDARY(id BIGINT) 
RETURNS STRING
IMMUTABLE
AS $$
    _S2_BOUNDARY(CAST(ID AS STRING))
$$;

CREATE OR REPLACE SECURE FUNCTION S2_BOUNDARY
(id BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(_S2_BOUNDARY(ID))
$$;