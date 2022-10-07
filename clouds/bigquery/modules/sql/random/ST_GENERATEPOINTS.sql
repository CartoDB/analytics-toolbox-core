----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.ST_GENERATEPOINTS`
(geog GEOGRAPHY, npoints INT64)
RETURNS ARRAY<GEOGRAPHY>
AS (
    (
        WITH bbox AS (
            -- compute the bounding box of the polygon
            SELECT `@@BQ_DATASET@@.__BBOX_FROM_GEOJSON`(ST_ASGEOJSON(geog)) AS box
        ),

        bbox_coords AS (
            -- break down the bbox array into minx, miny, maxx, maxy
            SELECT
                box[ORDINAL(1)] AS minx,
                box[ORDINAL(2)] AS miny,
                box[ORDINAL(3)] AS maxx,
                box[ORDINAL(4)] AS maxy
            FROM bbox
        ),

        bbox_data AS (
            -- compute area of bbox and put some handy values here too
            SELECT
                minx,
                miny,
                maxx,
                maxy,
                1.2 AS k, -- security factor to make it more likely that at least npoints fall within the polygon
                ST_AREA(
                    ST_MAKEPOLYGON(ST_MAKELINE([
                        ST_GEOGPOINT(minx, miny),
                        ST_GEOGPOINT(minx, maxy),
                        ST_GEOGPOINT(maxx, maxy),
                        ST_GEOGPOINT(maxx, miny),
                        ST_GEOGPOINT(minx, miny)
                        ]))
                ) AS bbox_area
            FROM bbox_coords
        ),

        point_seeds AS (
            -- generate enough values so that we will hopefully have at least npoints of them randomly placed inside geog
            SELECT
                GENERATE_ARRAY(1, CEIL(k * npoints * bbox_area / ST_AREA(geog))) AS i,
                SIN(miny * ACOS(-1) / 180.0) AS minsin,
                SIN(maxy * ACOS(-1) / 180.0) AS maxsin,
                180.0 / ACOS(-1) AS radtodeg
            FROM bbox_data
        ),

        bbox_points AS (
            -- compute the random points uniformly in the bbox;
            SELECT ST_GEOGPOINT(minx + RAND() * (maxx - minx), radtodeg * ASIN(minsin + RAND() * (maxsin - minsin))) AS point
            FROM bbox_coords, point_seeds, UNNEST(i)
        ),

        poly_points AS (
            -- now we need to select the points inside the polygon and number them, so we can limit
            -- the end result to npoints (note that we can't have a dynamic LIMIT)
            SELECT
                point,
                ROW_NUMBER() OVER () AS rn
            FROM bbox_points
            WHERE ST_WITHIN(point, geog)
        )

        -- finally select at most npoints  and return them in an array
        SELECT ARRAY(SELECT point FROM poly_points WHERE rn <= npoints)
    )
);
