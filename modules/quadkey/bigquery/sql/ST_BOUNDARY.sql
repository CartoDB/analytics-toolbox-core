----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__GEOJSONBOUNDARY_FROMQUADINT`
(quadint INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (quadint == null) {
        throw new Error('NULL argument passed to UDF');
    }
    const geojson = lib.quadintToGeoJSON(quadint);
    return JSON.stringify(geojson);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_BOUNDARY`
(quadint INT64)
RETURNS STRING
AS (
    ST_GEOGFROMGEOJSON(`@@BQ_PREFIX@@quadkey.__GEOJSONBOUNDARY_FROMQUADINT`(quadint))
);