----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.__GEOJSONBOUNDARY_FROMID`
(id INT64) 
RETURNS STRING 
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (id == null) {
        throw new Error('NULL argument passed to UDF');
    }
    
    const cornerLongLat = lib.FromHilbertQuadKey(lib.idToKey(id)).getCornerLatLngs();
    const geojson = {
        type: 'Polygon',
        coordinates: [[
            [cornerLongLat[0]['lng'],cornerLongLat[0]['lat']],
            [cornerLongLat[1]['lng'],cornerLongLat[1]['lat']],
            [cornerLongLat[2]['lng'],cornerLongLat[2]['lat']],
            [cornerLongLat[3]['lng'],cornerLongLat[3]['lat']],
            [cornerLongLat[0]['lng'],cornerLongLat[0]['lat']]
        ]]
    };
    return JSON.stringify(geojson);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.ST_BOUNDARY`
(id INT64)
RETURN GEOGRAPHY
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@s2.__GEOJSONBOUNDARY_FROMID`(id))
);