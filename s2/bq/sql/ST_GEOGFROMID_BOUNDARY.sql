-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.GEOJSONBOUNDARY_FROMID`
    (id INT64) 
    RETURNS STRING 
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    if(id == null)
    {
        throw new Error('NULL argument passed to UDF');
    }
    
    var cornerLongLat = S2.S2Cell.FromHilbertQuadKey(S2.idToKey(id)).getCornerLatLngs();
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
""";

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.ST_GEOGFROMID_BOUNDARY`
    (id INT64)
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PROJECTID@@`.@@BQ_DATASET_S2@@.GEOJSONBOUNDARY_FROMID(id))
);
