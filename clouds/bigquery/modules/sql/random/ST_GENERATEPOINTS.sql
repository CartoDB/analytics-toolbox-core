--------------------------------
-- Copyright (C) 2021-2024 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__ST_GENERATEPOINTS`
(geojson STRING, npoints INT64)
RETURNS ARRAY<STRING>
DETERMINISTIC
LANGUAGE js
OPTIONS (library = ["@@BQ_LIBRARY_BUCKET@@"])
AS """
    return lib.random.generateRandomPointsInPolygon(JSON.parse(geojson), npoints);
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_GENERATEPOINTS`
(geog GEOGRAPHY, npoints INT64)
RETURNS ARRAY<GEOGRAPHY>
AS (
    (
        SELECT ARRAY_AGG(ST_GEOGFROMGEOJSON(point))
        FROM UNNEST(`@@BQ_DATASET@@.__ST_GENERATEPOINTS`(ST_ASGEOJSON(geog), npoints)) AS point
    )
);
