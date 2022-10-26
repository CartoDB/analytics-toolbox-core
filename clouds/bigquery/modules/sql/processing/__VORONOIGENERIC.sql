----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__VORONOIGENERIC`
(points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>, type_of_voronoi STRING)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    WITH distinct_rounded_points AS (
        SELECT ST_GEOGPOINT(x, y) AS point FROM (
          SELECT DISTINCT ROUND(ST_X(point), 5) AS x, ROUND(ST_Y(point), 5) AS y
          FROM UNNEST(points) AS point
        )
    ),
    geojson_points AS (
        SELECT ARRAY_AGG(ST_ASGEOJSON(point)) AS array_points
        FROM distinct_rounded_points
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
