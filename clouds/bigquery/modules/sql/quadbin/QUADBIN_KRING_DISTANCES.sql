----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_ZXY_KRING_DISTANCES`
(origin STRUCT<z INT64, x INT64, y INT64>, size INT64)
AS ((
    WITH
    __t AS (
        SELECT
            `@@BQ_DATASET@@.QUADBIN_FROMZXY`(
                Origin.Z,
                MOD(Origin.X + Dx + (1 << Origin.Z), (1 << Origin.Z)),
                Origin.Y + Dy
            ) AS __index,
            GREATEST(ABS(Dx), ABS(Dy)) AS __distance -- Chebychev distance
        FROM
            UNNEST(GENERATE_ARRAY(-Size, Size)) AS Dx,
            UNNEST(GENERATE_ARRAY(-Size, Size)) AS Dy
        WHERE Origin.Y + Dy >= 0 AND Origin.Y + Dy < (1 << Origin.Z)
    ),

    __t_agg AS (
        SELECT
            __index,
            MIN(__distance) AS __distance
        FROM __t
        GROUP BY __index
    )

    SELECT ARRAY_AGG(STRUCT(__index AS Index, __distance AS Distance))
    FROM __t_agg
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_KRING_DISTANCES`
(origin INT64, size INT64)
AS (
    `@@BQ_DATASET@@.__QUADBIN_ZXY_KRING_DISTANCES`(
        `@@BQ_DATASET@@.QUADBIN_TOZXY`(
            COALESCE(
                IF(Origin < 0, NULL, Origin), ERROR('Invalid input origin')
            )
        ),
        COALESCE(IF(Size >= 0, Size, NULL), ERROR('Invalid input size')))
);
