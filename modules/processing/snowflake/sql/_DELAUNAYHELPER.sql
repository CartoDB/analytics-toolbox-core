----------------------------
-- Copyright (C) 2021 CARTO
----------------------------


CREATE OR REPLACE FUNCTION _DELAUNAYHELPER
(inputPoints ARRAY)
RETURNS ARRAY
AS $$ (
    WITH points AS (
        SELECT ARRAY_AGG(unnested.VALUE) AS arrayPoints,
            MIN(ST_X(TO_GEOGRAPHY(unnested.VALUE))) AS xMin,
            MIN(ST_Y(TO_GEOGRAPHY(unnested.VALUE))) AS yMin,
            MAX(ST_X(TO_GEOGRAPHY(unnested.VALUE))) AS xMax,
            MAX(ST_Y(TO_GEOGRAPHY(unnested.VALUE))) AS yMax,
            ABS(MAX(ST_X(TO_GEOGRAPHY(unnested.VALUE))) - MIN(ST_X(TO_GEOGRAPHY(unnested.VALUE)))) AS xExtent,
            ABS(MAX(ST_Y(TO_GEOGRAPHY(unnested.VALUE))) - MIN(ST_Y(TO_GEOGRAPHY(unnested.VALUE)))) AS yExtent
        FROM LATERAL FLATTEN(input => inputPoints) AS unnested
      ), voronoi AS (
      SELECT _VORONOIHELPER(
            arrayPoints, 
            ARRAY_CONSTRUCT(xMin - xExtent * 0.5, 
                            yMin - yExtent * 0.5, 
                            xMax + xExtent * 0.5, 
                            yMax + yExtent * 0.5),
            'poly') AS voronoiArray
        FROM points
       ), triplets AS (
        SELECT TO_GEOGRAPHY(unnestedPoints.VALUE) AS point, TO_GEOGRAPHY(unnestedVoronoi.VALUE) AS poly, ST_GEOHASH(TO_GEOGRAPHY(unnestedPoints.VALUE)) AS geoid
        FROM LATERAL FLATTEN(input => inputPoints) AS unnestedPoints, voronoi, LATERAL FLATTEN(input => voronoiArray) AS unnestedVoronoi
        WHERE ST_CONTAINS(TO_GEOGRAPHY(unnestedVoronoi.VALUE), TO_GEOGRAPHY(unnestedPoints.VALUE))
       )
        SELECT ARRAY_AGG(ST_ASGEOJSON(TO_GEOGRAPHY(CONCAT('LINESTRING (', ST_X(p1.point), ' ', ST_Y(p1.point), ', ' , ST_X(p2.point), ' ', ST_Y(p2.point), ', ', ST_X(p3.point), ' ', ST_Y(p3.point), ', ', ST_X(p1.point), ' ', ST_Y(p1.point), ')')))::STRING)
        FROM triplets AS p1
        JOIN triplets AS p2
        ON ST_INTERSECTS(p1.poly, p2.poly)
        AND p1.geoid != p2.geoid
        JOIN triplets AS p3
        ON ST_INTERSECTS(p1.poly, p3.poly) AND ST_INTERSECTS(p2.poly, p3.poly)
        AND p2.geoid != p3.geoid
        AND p1.geoid <= p2.geoid AND p2.geoid <= p3.geoid
)$$;