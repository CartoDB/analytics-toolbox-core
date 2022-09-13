----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__S2_BOUNDARY`
(id INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (
    library = ["@@BQ_LIBRARY_BUCKET@@"]
)
AS """
    if (id == null) {
        throw new Error('NULL argument passed to UDF');
    }
    
    const cornerLongLat = lib.s2.FromHilbertQuadKey(lib.s2.idToKey(id)).getCornerLatLngs();

    const wkt = `POLYGON((` +
        cornerLongLat[0]['lng'] + ` ` + cornerLongLat[0]['lat'] + `, ` +
        cornerLongLat[1]['lng'] + ` ` + cornerLongLat[1]['lat'] + `, ` +
        cornerLongLat[2]['lng'] + ` ` + cornerLongLat[2]['lat'] + `, ` +
        cornerLongLat[3]['lng'] + ` ` + cornerLongLat[3]['lat'] + `, ` +
        cornerLongLat[0]['lng'] + ` ` + cornerLongLat[0]['lat'] +
        `))`;

    return wkt;
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_BOUNDARY`
(id INT64)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMTEXT(
        `@@BQ_DATASET@@.__S2_BOUNDARY`(id)
    )
);
