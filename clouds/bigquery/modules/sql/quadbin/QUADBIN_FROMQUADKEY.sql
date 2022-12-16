----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_FROMQUADKEY`
(quadkey STRING)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
AS """
    const z = BigInt(quadkey.length);
    const xy = BigInt(parseInt(quadkey, 4) || 0);
    return (0x4000000000000000n |
        (1n << 59n) |
        (z << 52n) |
        (xy << (52n - z*2n)) |
        (0xfffffffffffffn >> (z*2n))).toString();
""";

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_FROMQUADKEY`
(quadkey STRING)
RETURNS INT64
AS (
    CAST(`@@BQ_DATASET@@.__QUADBIN_FROMQUADKEY`(quadkey) AS INT64)
);
