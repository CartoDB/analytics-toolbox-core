----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__S2_CENTER`(id INT64)
RETURNS STRUCT<lng FLOAT64,lat FLOAT64>
DETERMINISTIC
LANGUAGE js
OPTIONS (library=["@@BQ_LIBRARY_BUCKET@@"])
AS """
    if (id == null) {
        throw new Error('NULL argument passed to UDF');
    }
    return lib.s2.idToLatLng(String(id));
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_CENTER`
(id INT64)
RETURNS GEOGRAPHY
AS (
    ST_GEOGPOINT(`@@BQ_DATASET@@.__S2_CENTER`(id).lng,`@@BQ_DATASET@@.__S2_CENTER`(id).lat)
);