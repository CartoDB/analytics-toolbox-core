----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_CENTER`(quadbin INT64)
RETURNS GEOGRAPHY
AS (
    CASE
        WHEN quadbin IS NULL THEN
            NULL
        -- Deal with level 0 boundary issue.
        WHEN quadbin=5188146770730811392 THEN
            ST_GEOGPOINT(0,0)
        -- Deal with level 1. Prevent error from antipodal vertices.
        WHEN quadbin=5192650370358181888 THEN
            ST_GEOGPOINT(-90,45)
        WHEN quadbin=5193776270265024512 THEN
            ST_GEOGPOINT(90,45)
        WHEN quadbin=5194902170171867136 THEN
            ST_GEOGPOINT(-90,-45)
        WHEN quadbin=5196028070078709760 THEN
            ST_GEOGPOINT(90,-45)
        ELSE (
            WITH
            __zxy AS (
                SELECT
                    `@@BQ_PREFIX@@carto.QUADBIN_TOZXY`(quadbin) AS tile,
                    ACOS(-1) AS PI
            )
            SELECT ST_GEOGPOINT(
                180 * (2.0 * (tile.x + 0.5) / CAST((1 << tile.z) AS FLOAT64) - 1.0),
                360 * (ATAN(EXP(-(2.0 * (tile.y + 0.5) / CAST((1 << tile.z) AS FLOAT64) - 1) * PI)) / PI - 0.25)
            )
            FROM __zxy
        )
    END
);