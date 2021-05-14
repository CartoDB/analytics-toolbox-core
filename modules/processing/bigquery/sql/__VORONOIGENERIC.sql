----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@processing.__VORONOIGENERIC`
(points ARRAY<GEOGRAPHY>, bbox ARRAY<FLOAT64>, typeOfVoronoi STRING)
RETURNS ARRAY<GEOGRAPHY>
AS ((
   WITH geojsonPoints AS (
        SELECT ARRAY_AGG(ST_ASGEOJSON(p)) AS arrayPoints
        FROM UNNEST(points) AS p
    ),
    geojsonResult AS (
        SELECT `@@BQ_PREFIX@@processing.__VORONOIHELPER`(arrayPoints, bbox, typeOfVoronoi) AS features
        FROM geojsonPoints
    )
    SELECT ARRAY(
        SELECT ST_GEOGFROMGEOJSON(unnestedFeatures)
        FROM geojsonResult, UNNEST(features) as unnestedFeatures
    )
));