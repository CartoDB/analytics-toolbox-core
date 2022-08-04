----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__S2_CENTER`
(id INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS R"""
if (id == null) {
        throw new Error('NULL argument passed to UDF');
    }
    const latlng = s2Lib.idToLatLng(String(id));
    const wkt = `POINT(` + latlng.lng + ` ` + latlng.lat + `)`;
    return wkt;
""";

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.S2_CENTER`
(id INT64)
RETURNS GEOGRAPHY
AS (
    ST_GEOGFROMTEXT(`@@BQ_PREFIX@@carto.__S2_CENTER`(id))
);