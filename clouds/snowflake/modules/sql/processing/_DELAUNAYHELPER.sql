----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._DELAUNAYHELPER
(input_points ARRAY)
RETURNS ARRAY
AS $$ (
    WITH distinct_rounded_points AS (
        SELECT ST_POINT(x, y) AS point FROM (
          SELECT DISTINCT ROUND(ST_X(point), 5) AS x, ROUND(ST_Y(point), 5) AS y
          FROM (
            SELECT TO_GEOGRAPHY(point_json.VALUE) AS point
            FROM LATERAL FLATTEN(input => input_points) AS point_json
          )
        )
    ),
    points AS (
        SELECT ARRAY_AGG(CAST(ST_ASGEOJSON(point) AS STRING)) AS array_points,
            MIN(ST_X(point)) AS x_min,
            MIN(ST_Y(point)) AS y_min,
            MAX(ST_X(point)) AS x_max,
            MAX(ST_Y(point)) AS y_max,
            ABS(MAX(ST_X(point)) - MIN(ST_X(point))) AS x_extent,
            ABS(MAX(ST_Y(point)) - MIN(ST_Y(point))) AS y_extent
        FROM distinct_rounded_points
    ),
    voronoi AS (
        SELECT @@SF_SCHEMA@@._VORONOIHELPER(
            array_points,
            ARRAY_CONSTRUCT(x_min - x_extent * 0.5,
                            y_min - y_extent * 0.5,
                            x_max + x_extent * 0.5,
                            y_max + y_extent * 0.5),
            'poly'
        ) AS voronoi_array
        FROM points
    ),
    triplets AS (
        SELECT
           distinct_rounded_points.point,
           TO_GEOGRAPHY(unnested_voronoi.VALUE) AS poly,
           ST_GEOHASH(distinct_rounded_points.point) AS geoid
        FROM distinct_rounded_points, voronoi, LATERAL FLATTEN(input => voronoi_array) AS unnested_voronoi
        WHERE ST_CONTAINS(TO_GEOGRAPHY(unnested_voronoi.VALUE), distinct_rounded_points.point)
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
