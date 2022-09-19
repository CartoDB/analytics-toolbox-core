----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__VORONOIGENERIC`
(points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>, type_of_voronoi STRING)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    WITH geojson_points AS (
        SELECT ARRAY_AGG(ST_ASGEOJSON(p)) AS array_points
        FROM UNNEST(points) AS p
    ),

    geojsonresult AS (
        SELECT `@@BQ_DATASET@@.__VORONOIHELPER`(array_points, bbox, type_of_voronoi) AS features
        FROM geojson_points
    )

    SELECT ARRAY(
        SELECT ST_GEOGFROMGEOJSON(unnested_features)
        FROM geojsonresult, UNNEST(features) AS unnested_features
    )
));
