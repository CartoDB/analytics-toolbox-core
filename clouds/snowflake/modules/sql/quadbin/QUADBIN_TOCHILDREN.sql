----------------------------
-- Copyright (C) 2022-2023 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOCHILDREN
(quadbin BIGINT, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    WITH
    __constants AS (
    SELECT
        BITNOT(BITSHIFTLEFT(31, 52)) AS zoom_level_mask,
        BITSHIFTLEFT(
            1,
            BITSHIFTLEFT(
                (resolution - 
                BITAND(
                    BITSHIFTRIGHT(quadbin, 52),
                    31
                )),
                1
            )
        ) AS block_range,
        BITSHIFTLEFT(
            1,
            (resolution -
            BITAND(
                BITSHIFTRIGHT(quadbin, 52),
                31
            ))
        ) AS sqrt_block_range,
        (52 - BITSHIFTLEFT(resolution, 1)) AS block_shift
    ),
    __childbase_constants AS (
    SELECT
        BITAND(
            BITOR(
                BITAND(
                    quadbin,
                    zoom_level_mask
                ),
                BITSHIFTLEFT(resolution, 52)
            ),
            BITNOT(BITSHIFTLEFT((block_range - 1), block_shift))
        ) AS child_base
    FROM
        __constants
    ),
    __indexes AS (
        SELECT
            ARRAY_GENERATE_RANGE(0, sqrt_block_range ) AS block_rows,
            ARRAY_GENERATE_RANGE(0, sqrt_block_range ) AS block_columns
        FROM
            __constants
    )
    SELECT
        ARRAY_AGG(
            BITOR(
                child_base,
                BITSHIFTLEFT(
                    (block_row.value * sqrt_block_range + block_column.value),
                    block_shift
                )
            )
        )
    FROM
        __constants,
        __childbase_constants,
        __indexes,
        table(flatten( input => block_rows)) block_row,
        table(flatten( input => block_columns)) block_column
$$;
