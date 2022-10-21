----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._DELAUNAYHELPER
(inputPoints ARRAY)
RETURNS ARRAY
AS $$ (
    WITH distinct_rounded_points AS (
        SELECT ST_POINT(x, y) AS point FROM (
          SELECT DISTINCT ROUND(ST_X(point), 5) AS x, ROUND(ST_Y(point), 5) AS y
          FROM (
            SELECT TO_GEOGRAPHY(pointjson.VALUE) AS point
            FROM LATERAL FLATTEN(input => inputPoints) AS pointjson
          )
        )
    ),
    points AS (
        SELECT ARRAY_AGG(CAST(ST_ASGEOJSON(point) AS STRING)) AS arrayPoints,
            MIN(ST_X(point)) AS xMin,
            MIN(ST_Y(point)) AS yMin,
            MAX(ST_X(point)) AS xMax,
            MAX(ST_Y(point)) AS yMax,
            ABS(MAX(ST_X(point)) - MIN(ST_X(point))) AS xExtent,
            ABS(MAX(ST_Y(point)) - MIN(ST_Y(point))) AS yExtent
        FROM distinct_rounded_points
    ),
    voronoi AS (
        SELECT @@SF_SCHEMA@@._VORONOIHELPER(
            arrayPoints,
            ARRAY_CONSTRUCT(xMin - xExtent * 0.5,
                            yMin - yExtent * 0.5,
                            xMax + xExtent * 0.5,
                            yMax + yExtent * 0.5),
            'poly'
        ) AS voronoiArray
        FROM points
    ),
    triplets AS (
        SELECT
           distinct_rounded_points.point,
           TO_GEOGRAPHY(unnestedVoronoi.VALUE) AS poly,
           ST_GEOHASH(distinct_rounded_points.point) AS geoid
        FROM distinct_rounded_points, voronoi, LATERAL FLATTEN(input => voronoiArray) AS unnestedVoronoi
        WHERE ST_CONTAINS(TO_GEOGRAPHY(unnestedVoronoi.VALUE), distinct_rounded_points.point)
    )
    SELECT ARRAY_AGG(ST_ASGEOJSON(TO_GEOGRAPHY(CONCAT('LINESTRING (', ST_X(p1.point), ' ', ST_Y(p1.point), ', ' , ST_X(p2.point), ' ', ST_Y(p2.point), ', ', ST_X(p3.point), ' ', ST_Y(p3.point), ', ', ST_X(p1.point), ' ', ST_Y(p1.point), ')')))::STRING)
    FROM triplets AS p1
    JOIN triplets AS p2
      ON ST_INTERSECTS(p1.poly, p2.poly) AND p1.geoid != p2.geoid
    JOIN triplets AS p3
      ON ST_INTERSECTS(p1.poly, p3.poly) AND ST_INTERSECTS(p2.poly, p3.poly)
        AND p2.geoid != p3.geoid
        AND p1.geoid <= p2.geoid AND p2.geoid <= p3.geoid

)$$;
