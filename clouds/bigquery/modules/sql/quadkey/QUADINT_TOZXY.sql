----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_TOZXY`
(quadint INT64)
RETURNS STRUCT<z INT64, x INT64, y INT64>
AS (
    STRUCT (
        quadint & 0x1F AS z,
        (quadint >> 5) & ((1 << (quadint & 0x1F)) - 1) AS x,
        (quadint >> (5 + (quadint & 0x1F))) AS y
    )
);
