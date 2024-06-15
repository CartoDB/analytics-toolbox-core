---------------------------------
-- Copyright (C) 2022-2024 CARTO
---------------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`
(parent STRUCT<z INT64, x INT64, y INT64>, parent_inside BOOL, geog GEOGRAPHY, resolution INT64, resolution_level INT64)
RETURNS ARRAY<STRUCT<child STRUCT<z INT64, x INT64, y INT64>, inside BOOL>>
AS ((
    IF(resolution < resolution_level - 1, (
        WITH __parent AS (
            SELECT parent, parent_inside
        )
        SELECT ARRAY_AGG(p)
        FROM __parent p
    ), (
        WITH __params AS (
            SELECT (MOD(LEAST(resolution, resolution_level), 2) = 0) AS even
        ),
        __children AS (
            SELECT STRUCT(IF(even, parent.z + 2, parent.z + 1) AS z, x, y) AS child
            FROM __params,
                UNNEST(GENERATE_ARRAY(IF(even, 4 * parent.x, 2 * parent.x), IF(even, 4 * parent.x + 3, 2 * parent.x + 1))) AS x,
                UNNEST(GENERATE_ARRAY(IF(even, 4 * parent.y, 2 * parent.y), IF(even, 4 * parent.y + 3, 2 * parent.y + 1))) AS y
        ),
        __children_inside AS (
            SELECT child
            FROM __children
            WHERE parent_inside
        ),
        __children_border AS (
            SELECT child, `@@BQ_DATASET@@.__ZXY_BOUNDARY`(child) AS child_boundary
            FROM __children
            WHERE NOT parent_inside
        ),
        __children_union AS (
            SELECT child, TRUE AS inside
            FROM __children_inside
            UNION ALL
            SELECT child, ST_CONTAINS(geog, child_boundary) AS inside
            FROM __children_border
            WHERE ST_INTERSECTS(geog, child_boundary)
        )
        SELECT ARRAY_AGG(cu)
        FROM __children_union cu
    ))
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_CONTAINS`
(parent STRUCT<z INT64, x INT64, y INT64>, parent_inside BOOL, geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRUCT<z INT64, x INT64, y INT64>>
AS ((
    WITH __children AS (
        SELECT STRUCT(parent.z + 1 AS z, x, y) AS child
        FROM
            UNNEST(GENERATE_ARRAY(2 * parent.x, 2 * parent.x + 1)) AS x,
            UNNEST(GENERATE_ARRAY(2 * parent.y, 2 * parent.y + 1)) AS y
    ),
    __children_inside AS (
        SELECT child
        FROM __children
        WHERE parent_inside
    ),
    __children_border AS (
        SELECT child, `@@BQ_DATASET@@.__ZXY_BOUNDARY`(child) AS child_boundary
        FROM __children
        WHERE NOT parent_inside
    ),
    __children_union AS (
        SELECT child
        FROM __children_inside
        UNION ALL
        SELECT child
        FROM __children_border
        WHERE ST_CONTAINS(geog, child_boundary)
    )
    SELECT ARRAY_AGG(child)
    FROM __children_union
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_CENTER`
(parent STRUCT<z INT64, x INT64, y INT64>, parent_inside BOOL, geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<STRUCT<z INT64, x INT64, y INT64>>
AS ((
    WITH __children AS (
        SELECT STRUCT(parent.z + 1 AS z, x, y) AS child
        FROM
            UNNEST(GENERATE_ARRAY(2 * parent.x, 2 * parent.x + 1)) AS x,
            UNNEST(GENERATE_ARRAY(2 * parent.y, 2 * parent.y + 1)) AS y
    ),
    __children_inside AS (
        SELECT child
        FROM __children
        WHERE parent_inside
    ),
    __children_border AS (
        SELECT child, `@@BQ_DATASET@@.__ZXY_CENTER`(child) AS child_center
        FROM __children
        WHERE NOT parent_inside
    ),
    __children_union AS (
        SELECT child
        FROM __children_inside
        UNION ALL
        SELECT child
        FROM __children_border
        WHERE ST_INTERSECTS(geog, child_center)
    )
    SELECT ARRAY_AGG(child)
    FROM __children_union
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INTERSECTS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    SELECT ARRAY_AGG(`@@BQ_DATASET@@.QUADBIN_FROMZXY`(q26.child.z, q26.child.x, q26.child.y))
    FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(STRUCT(0, 0, 0), FALSE, geog, resolution, 2)) q2
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q2.child, q2.inside, geog, resolution, 4)) q4
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q4.child, q4.inside, geog, resolution, 6)) q6
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q6.child, q6.inside, geog, resolution, 8)) q8
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q8.child, q8.inside, geog, resolution, 10)) q10
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q10.child, q10.inside, geog, resolution, 12)) q12
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q12.child, q12.inside, geog, resolution, 14)) q14
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q14.child, q14.inside, geog, resolution, 16)) q16
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q16.child, q16.inside, geog, resolution, 18)) q18
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q18.child, q18.inside, geog, resolution, 20)) q20
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q20.child, q20.inside, geog, resolution, 22)) q22
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q22.child, q22.inside, geog, resolution, 24)) q24
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q24.child, q24.inside, geog, resolution, 26)) q26
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CONTAINS`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    SELECT ARRAY_AGG(`@@BQ_DATASET@@.QUADBIN_FROMZXY`(q.z, q.x, q.y))
    FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(STRUCT(0, 0, 0), FALSE, geog, resolution-1, 2)) q2
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q2.child, q2.inside, geog, resolution-1, 4)) q4
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q4.child, q4.inside, geog, resolution-1, 6)) q6
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q6.child, q6.inside, geog, resolution-1, 8)) q8
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q8.child, q8.inside, geog, resolution-1, 10)) q10
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q10.child, q10.inside, geog, resolution-1, 12)) q12
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q12.child, q12.inside, geog, resolution-1, 14)) q14
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q14.child, q14.inside, geog, resolution-1, 16)) q16
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q16.child, q16.inside, geog, resolution-1, 18)) q18
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q18.child, q18.inside, geog, resolution-1, 20)) q20
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q20.child, q20.inside, geog, resolution-1, 22)) q22
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q22.child, q22.inside, geog, resolution-1, 24)) q24
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q24.child, q24.inside, geog, resolution-1, 26)) q26
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_CONTAINS`(q26.child, q26.inside, geog, resolution)) q
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CENTER`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    SELECT ARRAY_AGG(`@@BQ_DATASET@@.QUADBIN_FROMZXY`(q.z, q.x, q.y))
    FROM UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(STRUCT(0, 0, 0), FALSE, geog, resolution-1, 2)) q2
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q2.child, q2.inside, geog, resolution-1, 4)) q4
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q4.child, q4.inside, geog, resolution-1, 6)) q6
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q6.child, q6.inside, geog, resolution-1, 8)) q8
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q8.child, q8.inside, geog, resolution-1, 10)) q10
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q10.child, q10.inside, geog, resolution-1, 12)) q12
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q12.child, q12.inside, geog, resolution-1, 14)) q14
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q14.child, q14.inside, geog, resolution-1, 16)) q16
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q16.child, q16.inside, geog, resolution-1, 18)) q18
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q18.child, q18.inside, geog, resolution-1, 20)) q20
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q20.child, q20.inside, geog, resolution-1, 22)) q22
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q22.child, q22.inside, geog, resolution-1, 24)) q24
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_INTERSECTS`(q24.child, q24.inside, geog, resolution-1, 26)) q26
    JOIN UNNEST(`@@BQ_DATASET@@.__QUADBIN_POLYFILL_STEP_CENTER`(q26.child, q26.inside, geog, resolution)) q
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_POLYFILL_MODE`
(geog GEOGRAPHY, resolution INT64, mode STRING)
RETURNS ARRAY<INT64>
AS ((
    CASE mode
        WHEN 'intersects' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_INTERSECTS`(geog, resolution)
        WHEN 'contains' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CONTAINS`(geog, resolution)
        WHEN 'center' THEN `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CENTER`(geog, resolution)
    END
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_POLYFILL`
(geog GEOGRAPHY, resolution INT64)
RETURNS ARRAY<INT64>
AS ((
    `@@BQ_DATASET@@.__QUADBIN_POLYFILL_CENTER`(geog, resolution)
));
