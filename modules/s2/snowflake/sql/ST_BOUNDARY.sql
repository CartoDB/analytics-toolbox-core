----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID
(id STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!ID) {
        throw new Error('NULL argument passed to UDF');
    }

    function setup() {
        @@SF_LIBRARY_CONTENT@@
        s2LibGlobal = s2Lib;
    }

    if (typeof(s2LibGlobal) === "undefined") {
        setup();
    }

    const cornerLongLat = s2LibGlobal.FromHilbertQuadKey(s2LibGlobal.idToKey(ID)).getCornerLatLngs();
    const wkt = `POLYGON((` +
        cornerLongLat[0]['lng'] + ` ` + cornerLongLat[0]['lat'] + `, ` +
        cornerLongLat[1]['lng'] + ` ` + cornerLongLat[1]['lat'] + `, ` +
        cornerLongLat[2]['lng'] + ` ` + cornerLongLat[2]['lat'] + `, ` +
        cornerLongLat[3]['lng'] + ` ` + cornerLongLat[3]['lat'] + `, ` +
        cornerLongLat[0]['lng'] + ` ` + cornerLongLat[0]['lat'] +
        `))`;
    return wkt;
$$;

CREATE OR REPLACE FUNCTION @@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID
(id BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    @@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID(CAST(ID AS STRING))
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@s2.ST_BOUNDARY
(id BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TRY_TO_GEOGRAPHY(@@SF_PREFIX@@s2._GEOJSONBOUNDARY_FROMID(ID))
$$;