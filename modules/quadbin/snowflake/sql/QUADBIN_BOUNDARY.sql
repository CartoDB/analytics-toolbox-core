----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE
OR REPLACE FUNCTION QUADBIN_BOUNDARY(quadbin BIGINT)
RETURNS GEOGRAPHY
AS $$
CASE quadbin
    WHEN NULL THEN NULL -- Deal with level 0 boundary issue.
    WHEN 5192650370358181887 THEN TO_GEOGRAPHY(
        '{"coordinates":[[[-180,85.0511287798066],[-180,-85.0511287798066],[180,-85.0511287798066],[180,85.0511287798066],[-180,85.0511287798066]]],"type":"Polygon"}'
    ) -- Deal with level 1. Prevent error from antipodal vertices.
    WHEN 5193776270265024511 THEN TO_GEOGRAPHY (
        'POLYGON((0 0, 0 85.0511287798066, -180 85.0511287798066, -180 0, -90 0, 0 0))'
    )
    WHEN 5194902170171867135 THEN TO_GEOGRAPHY (
        'POLYGON((180 0, 180 85.0511287798066, 0 85.0511287798066, 0 0, 90 0, 180 0))'
    )
    WHEN 5196028070078709759 THEN TO_GEOGRAPHY (
        'POLYGON((0 0, -90 0, 180 0, -180 -85.0511287798066, 0 -85.0511287798066, 0 0))'
    )
    WHEN 5197153969985552383 THEN TO_GEOGRAPHY (
        'POLYGON((180 0, 90 0, 0 0, 0 -85.0511287798066, 180 -85.0511287798066, 180 0))'
    )
    ELSE (
        WITH __bbox AS (
            SELECT
                QUADBIN_BBOX(quadbin) AS b
        ),
        __line_a AS (
            SELECT
                ST_MAKELINE(
                    ST_POINT(b [0], b [3]),
                    ST_POINT(b [0], b [1])
                ) as line
            FROM
                __bbox
        ),
        __line_b AS (
            SELECT
                ST_MAKELINE(
                    ST_POINT(b [2], b [1]),
                    ST_POINT(b [2], b [3])
                ) as line
            FROM
                __bbox
        ),
        __line_c AS (
            SELECT
                ST_MAKELINE(
                    __line_a.line,
                    __line_b.line
                ) as line
            FROM
                __line_a,
                __line_b
        )
        SELECT
            ST_MAKEPOLYGON(
                ST_MAKELINE(
                    __line_c.line,
                    ST_POINT(b [0], b [3])
                )
            )
        FROM
            __bbox,
            __line_c
    )
END
$$;