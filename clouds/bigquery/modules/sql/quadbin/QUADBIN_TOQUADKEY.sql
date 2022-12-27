----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_TOQUADKEY`
(quadbin INT64)
RETURNS STRING
DETERMINISTIC
LANGUAGE js
AS """
    const q = BigInt(quadbin);
    const z = (q >> 52n) & 0x1Fn;
    const xy = (q & 0xFFFFFFFFFFFFFn) >> (52n - z*2n);
    return (z == 0) ? '' : xy.toString(4).padStart(Number(z), '0');
""";
