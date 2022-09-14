----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__DELAUNAYGENERIC`
(inputPoints ARRAY<GEOGRAPHY>)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    WITH points AS (
        SELECT ARRAY_AGG(unnested) AS arrayPoints,
            MIN(ST_X(unnested)) AS xMin,
            MIN(ST_Y(unnested)) AS yMin,
            MAX(ST_X(unnested)) AS xMax,
            MAX(ST_Y(unnested)) AS yMax,
            ABS(MAX(ST_X(unnested)) - MIN(ST_X(unnested))) AS xExtent,
            ABS(MAX(ST_Y(unnested)) - MIN(ST_Y(unnested))) AS yExtent,
        FROM UNNEST(inputPoints) AS unnested
    ),
    voronoi AS (
        -- A 50% larger BBOX is applied to avoid issues with very large Voronoi polygons
        SELECT `@@BQ_DATASET@@.__VORONOIGENERIC`(arrayPoints, 
            [xMin - xExtent * 0.5, 
            yMin - yExtent * 0.5, 
            xMax + xExtent * 0.5, 
            yMax + yExtent * 0.5],
            'poly') AS voronoiArray, 
        FROM points
    ),
    triplets AS (
        SELECT STRUCT(unnestedPoints AS point, unnestedVoronoi AS poly, ST_GEOHASH(unnestedPoints) AS geoid) AS dual
        FROM UNNEST(inputPoints) AS unnestedPoints, voronoi, UNNEST(voronoiArray) AS unnestedVoronoi
        WHERE ST_CONTAINS(unnestedVoronoi, unnestedPoints)
    )
    SELECT ARRAY(
        SELECT ST_MAKELINE([p1.dual.point, p2.dual.point, p3.dual.point, p1.dual.point]) AS triangle
        FROM triplets AS p1
        JOIN triplets AS p2
        ON ST_TOUCHES(p1.dual.poly, p2.dual.poly)
        AND ST_EQUALS(p1.dual.point, p2.dual.point) = FALSE
        JOIN triplets AS p3
        ON ST_TOUCHES(p1.dual.poly, p3.dual.poly) AND ST_TOUCHES(p2.dual.poly, p3.dual.poly)
        AND ST_EQUALS(p2.dual.point, p3.dual.point) = FALSE
        AND p1.dual.geoid <= p2.dual.geoid AND p2.dual.geoid <= p3.dual.geoid
    )
));