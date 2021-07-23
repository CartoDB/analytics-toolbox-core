----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.__ST_GEOGPOINTFROMQUADINT`
(quadint INT64)
RETURNS STRUCT<longitude FLOAT64, latitude FLOAT64>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (quadint == null) {
        throw new Error('NULL argument passed to UDF');
    }
    return quadkeyLib.centroid(quadint);
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@quadkey.ST_GEOGPOINTFROMQUADINT`
(quadint INT64)
RETURNS GEOGRAPHY
AS (
    ST_GEOGPOINT(
    `@@BQ_PREFIX@@quadkey.__GEOJSONBOUNDARY_FROMQUADINT`(quadint).longitude,
    `@@BQ_PREFIX@@quadkey.__GEOJSONBOUNDARY_FROMQUADINT`(quadint).latitude
    )
);