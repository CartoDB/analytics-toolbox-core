----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__DELAUNAYGENERIC`
(inputPoints ARRAY<GEOGRAPHY>)
RETURNS ARRAY<GEOGRAPHY>
AS ((
    WITH distinct_rounded_points AS (
        SELECT ST_GEOGPOINT(x, y) AS point FROM (
          SELECT DISTINCT ROUND(ST_X(point), 5) AS x, ROUND(ST_Y(point),5) AS y
          FROM UNNEST(inputpoints) AS point
        )
    ),
    points AS (
        SELECT
            ARRAY_AGG(point) AS arraypoints,
            MIN(ST_X(point)) AS xmin,
            MIN(ST_Y(point)) AS ymin,
            MAX(ST_X(point)) AS xmax,
            MAX(ST_Y(point)) AS ymax,
            ABS(MAX(ST_X(point)) - MIN(ST_X(point))) AS xextent,
            ABS(MAX(ST_Y(point)) - MIN(ST_Y(point))) AS yextent
        FROM distinct_rounded_points
    ),

    voronoi AS (
        -- A 50% larger BBOX is applied to avoid issues with very large Voronoi polygons
        SELECT `@@BQ_DATASET@@.__VORONOIGENERIC`(
                arraypoints,
                [xmin - xextent * 0.5,
                    ymin - yextent * 0.5,
                    xmax + xextent * 0.5,
                    ymax + yextent * 0.5],
                'poly') AS voronoiarray
        FROM points
    ),

    triplets AS (
        SELECT STRUCT(
                unnestedpoints AS point,
                unnestedvoronoi AS poly,
                ST_GEOHASH(unnestedpoints) AS geoid
            ) AS dual
        FROM
            points, UNNEST(arraypoints) AS unnestedpoints,
            voronoi, UNNEST(voronoiarray) AS unnestedvoronoi
        WHERE ST_CONTAINS(unnestedvoronoi, unnestedpoints)
    )

    SELECT ARRAY(
        SELECT ST_MAKELINE(
                [p1.dual.point, p2.dual.point, p3.dual.point, p1.dual.point]
            ) AS triangle
        FROM triplets AS p1
        INNER JOIN triplets AS p2
            ON ST_TOUCHES(p1.dual.poly, p2.dual.poly)
                AND ST_EQUALS(p1.dual.point, p2.dual.point) = FALSE
        INNER JOIN triplets AS p3
            ON
                ST_TOUCHES(
                    p1.dual.poly, p3.dual.poly
                ) AND ST_TOUCHES(p2.dual.poly, p3.dual.poly)
                AND ST_EQUALS(p2.dual.point, p3.dual.point) = FALSE
                AND p1.dual.geoid <= p2.dual.geoid AND p2.dual.geoid <= p3.dual.geoid
    )
));
