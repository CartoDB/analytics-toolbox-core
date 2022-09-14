----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__VORONOIGENERIC`
(points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>, typeofvoronoi STRING)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    WITH geojsonpoints AS (
        SELECT ARRAY_AGG(ST_ASGEOJSON(p)) AS arraypoints
        FROM UNNEST(points) AS p
    ),

    geojsonresult AS (
        SELECT `@@BQ_DATASET@@.__VORONOIHELPER`(arraypoints, bbox, typeofvoronoi) AS features
        FROM geojsonpoints
    )

    SELECT ARRAY(
        SELECT ST_GEOGFROMGEOJSON(unnestedfeatures)
        FROM geojsonresult, UNNEST(features) AS unnestedfeatures
    )
));
