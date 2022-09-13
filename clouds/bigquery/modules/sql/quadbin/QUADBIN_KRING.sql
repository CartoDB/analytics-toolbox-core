----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_ZXY_KRING`
(origin STRUCT<z INT64, x INT64, y INT64>, size INT64)
AS ((
    SELECT ARRAY_AGG(
        DISTINCT(
            `@@BQ_DATASET@@.QUADBIN_FROMZXY`(
                origin.z,
                MOD(origin.x + dx + (1 << origin.z), (1 << origin.z)),
                origin.y + dy)
        )
    )
    FROM
        UNNEST(GENERATE_ARRAY(-size, size)) AS dx,
        UNNEST(GENERATE_ARRAY(-size, size)) AS dy
    WHERE origin.y + dy >= 0 AND origin.y + dy < (1 << origin.z)
));

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_KRING`
(origin INT64, size INT64)
AS (
    `@@BQ_DATASET@@.__QUADBIN_ZXY_KRING`(
        `@@BQ_DATASET@@.QUADBIN_TOZXY`(
            COALESCE(
                IF(origin < 0, NULL, origin), ERROR('Invalid input origin')
            )
        ),
        COALESCE(IF(size >= 0, size, NULL), ERROR('Invalid input size'))
    )
);
