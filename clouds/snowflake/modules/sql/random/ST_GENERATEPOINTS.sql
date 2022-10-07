----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_GENERATEPOINTS
(geog GEOGRAPHY, npoints INT)
RETURNS ARRAY
VOLATILE
AS $$(
    WITH bbox AS (
    -- compute the bounding box of the polygon
        SELECT @@SF_SCHEMA@@._BBOX_FROM_GEOJSON(ST_ASGEOJSON(GEOG)::STRING) AS box
    ),
    bbox_coords AS (
        -- break down the bbox array into minx, miny, maxx, maxy
        SELECT
            GET(box, 0) AS minx, GET(box, 1) AS miny,
            GET(box, 2) AS maxx, GET(box, 3) AS maxy
        FROM bbox
    ),
    bbox_data AS (
        -- compute area of bbox and put some handy values here too
        SELECT minx, miny, maxx, maxy,
            1.2 AS k, -- security factor to make it more likely that at least npoints fall within the polygon
            ST_AREA(@@SF_SCHEMA@@.ST_MAKEENVELOPE(minx, miny, maxx, maxy)) AS bbox_area,
            CEIL(k*NPOINTS*bbox_area/ST_AREA(GEOG)) AS nRows
        FROM bbox_coords
    ),
    point_seeds AS (
        -- generate enough values so that we will hopefully have at least npoints of them randomly placed inside geog
        SELECT SPLIT(lpad('', (nRows - 1), '0'),'0') as rowsArray,
        SIN(miny*PI()/180.0) AS minsin,
        SIN(maxy*PI()/180.0) AS maxsin,
        180.0/PI() AS radtodeg
        FROM bbox_data
    ),
    bbox_points AS (
        -- compute the random points uniformly in the bbox;
        SELECT
            ST_POINT(minx+UNIFORM(0::FLOAT, 1::FLOAT, random())*(maxx-minx), radtodeg*ASIN(minsin+UNIFORM(0::FLOAT, 1::FLOAT, random())*(maxsin-minsin))) AS point
        FROM bbox_coords, point_seeds, lateral FLATTEN(input => rowsArray)
    ),
    poly_points AS (
        -- now we need to select the points inside the polygon and number them, so we can limit
        -- the end result to npoints (note that we can't have a dynamic LIMIT)
        SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rn, point
        FROM bbox_points
        WHERE ST_WITHIN(point, GEOG)
    )
    -- finally select at most npoints  and return them in an array
    SELECT ARRAY_AGG(ST_ASGEOJSON(point)::STRING)
    FROM poly_points WHERE rn <= NPOINTS
)$$;
