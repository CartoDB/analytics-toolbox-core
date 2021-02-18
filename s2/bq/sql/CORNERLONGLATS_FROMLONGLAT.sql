-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PROJECTID@@.@@BQ_DATASET_S2@@.CORNERLONGLATS_FROMLONGLAT`
    (longitude FLOAT64, latitude FLOAT64, level NUMERIC) 
    RETURNS STRING 
    DETERMINISTIC
    LANGUAGE js
    OPTIONS (library=["@@S2_BQ_LIBRARY@@"])
AS """
    var cornerLongLat = S2.S2Cell.FromLatLng({ lat: latitude, lng: longitude }, level).getCornerLatLngs();
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
