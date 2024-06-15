----------------------------
-- Copyright (C) 2024 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__ZXY_CENTER`(
    tile STRUCT<z INT64, x INT64, y INT64>
)
RETURNS GEOGRAPHY
AS (
    CASE tile
        WHEN NULL THEN
            NULL
        -- Deal with level 0 boundary issue.
        WHEN (0, 0, 0) THEN
            ST_GEOGPOINT(0, 0)
        -- Deal with level 1. Prevent error from antipodal vertices.
        WHEN (1, 0, 0) THEN
            ST_GEOGPOINT(-90, 45)
        WHEN (1, 1, 0) THEN
            ST_GEOGPOINT(90, 45)
        WHEN (1, 0, 1) THEN
            ST_GEOGPOINT(-90, -45)
        WHEN (1, 1, 1) THEN
            ST_GEOGPOINT(90, -45)
        ELSE (
            WITH
            __params AS (
                SELECT
                    tile.x AS x,
                    tile.y AS y,
                    CAST((1 << tile.z) AS FLOAT64) AS s,
                    3.1415926535897931 AS pi
            )
            SELECT ST_GEOGPOINT(
                180 * (2 * (x + 0.5) / s - 1),
                360 * (ATAN(EXP(-(2 * (y + 0.5) / s - 1) * pi)) / pi - 0.25)
            )
            FROM __params
        )
    END
);
