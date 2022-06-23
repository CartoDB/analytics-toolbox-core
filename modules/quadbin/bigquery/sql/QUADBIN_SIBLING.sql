----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__ZXY_QUADBIN_SIBLING`
(origin STRUCT<z INT64, x INT64, y INT64>, dx INT64, dy INT64)
AS (
    IF(origin.y + dy >= 0 AND origin.y + dy < (1 << origin.z),
        `@@BQ_PREFIX@@carto.QUADBIN_FROMZXY`(
            origin.z,
            MOD(origin.x + dx, (1 << origin.z)) + IF(origin.x + dx < 0, (1 << origin.z), 0),
            origin.y + dy
        ),
        NULL
    )
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADBIN_SIBLING`
(origin INT64, dx INT64, dy INT64)
AS (
    `@@BQ_PREFIX@@carto.__ZXY_QUADBIN_SIBLING`(
        `@@BQ_PREFIX@@carto.QUADBIN_TOZXY`(
            IFNULL(
                IF(origin < 0, ERROR('QUADBIN cannot be negative'), origin),
                ERROR('NULL argument passed to UDF')
            )
        ),
        IFNULL(dx, ERROR('Invalid input dx')),
        IFNULL(dy, ERROR('Invalid input dy'))
    )
);

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.QUADBIN_SIBLING`
(quadbin INT64, direction STRING)
AS (
    CASE direction
        WHEN 'left' THEN
            `@@BQ_PREFIX@@carto.__QUADBIN_SIBLING`(quadbin, -1, 0)
        WHEN 'right' THEN
            `@@BQ_PREFIX@@carto.__QUADBIN_SIBLING`(quadbin, 1, 0)
        WHEN 'up' THEN
            `@@BQ_PREFIX@@carto.__QUADBIN_SIBLING`(quadbin, 0, -1)
        WHEN 'down' THEN
            `@@BQ_PREFIX@@carto.__QUADBIN_SIBLING`(quadbin, 0, 1)
        ELSE (
            ERROR('Wrong direction argument passed to sibling')
        )
    END
);