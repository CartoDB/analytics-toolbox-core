----------------------------
-- Copyright (C) 2024 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__ZXY_BOUNDARY`(
    tile STRUCT<z INT64, x INT64, y INT64>
)
RETURNS GEOGRAPHY
AS (
    CASE tile
        WHEN NULL THEN
            NULL
        -- Deal with level 0 boundary issue.
        WHEN (0, 0, 0) THEN
            ST_GEOGFROMGEOJSON(
                '{"coordinates":[[[-180,85.0511287798066],[-180,-85.0511287798066],[180,-85.0511287798066],[180,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}'
            )
        -- Deal with level 1. Prevent error from antipodal vertices.
        WHEN (1, 0, 0) THEN
            ST_GEOGFROMTEXT(
                'POLYGON((0 0, 0 85.0511287798066, -180 85.0511287798066, -180 0, -90 0, 0 0))'
            )
        WHEN (1, 1, 0) THEN
            ST_GEOGFROMTEXT(
                'POLYGON((180 0, 180 85.0511287798066, 0 85.0511287798066, 0 0, 90 0, 180 0))'
            )
        WHEN (1, 0, 1) THEN
            ST_GEOGFROMTEXT(
                'POLYGON((0 0, -90 0, 180 0, -180 -85.0511287798066, 0 -85.0511287798066, 0 0))'
            )
        WHEN (1, 1, 1) THEN
            ST_GEOGFROMTEXT(
                'POLYGON((180 0, 90 0, 0 0, 0 -85.0511287798066, 180 -85.0511287798066, 180 0))'
            )
        ELSE (
            WITH
            __params AS (
                SELECT
                    tile.x AS x,
                    tile.y AS y,
                    CAST((1 << tile.z) AS FLOAT64) AS s,
                    3.1415926535897931 AS pi
            ),
            __bbox AS (
                SELECT [
                    180 * (2 * x / s  - 1),
                    360 * (ATAN(EXP(-(2 * (y + 1) / s - 1) * pi)) / pi - 0.25),
                    180 * (2 * (x + 1) / s - 1),
                    360 * (ATAN(EXP(-(2 * y / s - 1) * pi)) / pi - 0.25)
                ] AS bbox
                FROM __params
            )
            SELECT ST_MAKEPOLYGON(ST_MAKELINE([
                ST_GEOGPOINT(bbox[OFFSET(0)], bbox[OFFSET(3)]),
                ST_GEOGPOINT(bbox[OFFSET(0)], bbox[OFFSET(1)]),
                ST_GEOGPOINT(bbox[OFFSET(2)], bbox[OFFSET(1)]),
                ST_GEOGPOINT(bbox[OFFSET(2)], bbox[OFFSET(3)]),
                ST_GEOGPOINT(bbox[OFFSET(0)], bbox[OFFSET(3)])
            ]))
            FROM __bbox
        )
    END
);
