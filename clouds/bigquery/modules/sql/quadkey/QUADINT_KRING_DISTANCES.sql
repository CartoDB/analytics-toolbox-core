----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADINT_ZXY_KRING_DISTANCES`
(origin STRUCT<z INT64, x INT64, y INT64>, size INT64)
AS ((
    WITH T AS (
        SELECT
            `@@BQ_DATASET@@.QUADINT_FROMZXY`(
                ORIGIN.Z,
                MOD(
                    ORIGIN.X + DX + (1 << ORIGIN.Z),
                    (1 << ORIGIN.Z)
                ),
                ORIGIN.Y + DY
            ) AS MYINDEX,
            GREATEST(ABS(DX), ABS(DY)) AS DISTANCE -- Chebychev distance
        FROM
            UNNEST(GENERATE_ARRAY(-SIZE, SIZE)) AS DX,
            UNNEST(GENERATE_ARRAY(-SIZE, SIZE)) AS DY
        WHERE ORIGIN.Y + DY >= 0 AND ORIGIN.Y + DY < (1 << ORIGIN.Z)
    ),

    T_AGG AS (
        SELECT
            MYINDEX,
            MIN(DISTANCE) AS DISTANCE
        FROM
            T
        GROUP BY
            MYINDEX
    )

    SELECT ARRAY_AGG(STRUCT(MYINDEX AS INDEX, DISTANCE))
    FROM T_AGG
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_KRING_DISTANCES`
(origin INT64, size INT64)
AS (
    `@@BQ_DATASET@@.__QUADINT_ZXY_KRING_DISTANCES`(
        `@@BQ_DATASET@@.QUADINT_TOZXY`(
            COALESCE(
                IF(ORIGIN < 0, NULL, ORIGIN), ERROR('Invalid input origin')
            )
        ),
        COALESCE(IF(SIZE >= 0, SIZE, NULL), ERROR('Invalid input size'))));
