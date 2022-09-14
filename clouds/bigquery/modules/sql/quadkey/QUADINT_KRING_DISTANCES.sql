----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADINT_ZXY_KRING_DISTANCES`
(origin STRUCT<z INT64, x INT64, y INT64>, size INT64)
AS ((
    WITH t AS (
        SELECT
            `@@BQ_DATASET@@.QUADINT_FROMZXY`(
                origin.z,
                MOD(
                    origin.x + dx + (1 << origin.z),
                    (1 << origin.z)
                ),
                origin.y + dy
            ) AS index,
            GREATEST(ABS(dx), ABS(dy)) AS distance -- Chebychev distance
        FROM
            UNNEST(GENERATE_ARRAY(-size, size)) AS dx,
            UNNEST(GENERATE_ARRAY(-size, size)) AS dy
        WHERE origin.y + dy >= 0 AND origin.y + dy < (1 << origin.z)
    ),

    t_agg AS (
        SELECT
            index,
            MIN(distance) AS distance
        FROM
            t
        GROUP BY
            index
    )

    SELECT ARRAY_AGG(STRUCT(index, distance))
    FROM t_agg
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_KRING_DISTANCES`
(origin INT64, size INT64)
AS (
    `@@BQ_DATASET@@.__QUADINT_ZXY_KRING_DISTANCES`(
        `@@BQ_DATASET@@.QUADINT_TOZXY`(
            COALESCE(
                IF(origin < 0, NULL, origin), ERROR('Invalid input origin')
            )
        ),
        COALESCE(IF(size >= 0, size, NULL), ERROR('Invalid input size'))));
