----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADBIN_ZXY_KRING_DISTANCES`
(origin STRUCT<z INT64, x INT64, y INT64>, size INT64)
AS ((
    WITH
    __t AS (
        SELECT
            `@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(
                origin.z,
                MOD(origin.x + dx + (1 << origin.z), (1 << origin.z)),
                origin.y + dy
            ) __index,
            GREATEST(ABS(dx), ABS(dy)) __distance -- Chebychev distance
        FROM
            UNNEST(GENERATE_ARRAY(-size,size)) dx,
            UNNEST(GENERATE_ARRAY(-size,size)) dy
        WHERE origin.y + dy >= 0 and origin.y + dy < (1 << origin.z)
    ),
    __t_agg AS (
        SELECT
            __index,
            MIN(__distance) AS __distance
        FROM __t
        GROUP BY __index
    )
    SELECT ARRAY_AGG(STRUCT(__index AS index, __distance AS distance))
    FROM __t_agg
));

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_KRING_DISTANCES`
(origin INT64, size INT64)
AS (
    `@@BQ_PREFIX@@carto.__QUADBIN_ZXY_KRING_DISTANCES`(
        `@@BQ_PREFIX@@carto.QUADBIN_TOZXY`(
            IFNULL(IF(origin < 0, NULL, origin), ERROR('Invalid input origin'))
        ),
        IFNULL(IF(size >= 0, size, NULL), ERROR('Invalid input size')))
);