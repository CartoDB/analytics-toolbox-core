----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_FROMQUADKEY
(quadkey STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    const z = BigInt(QUADKEY.length);
    const xy = BigInt(parseInt(QUADKEY, 4) || 0);
    return (0x4000000000000000n |
        (1n << 59n) |
        (z << 52n) |
        (xy << (52n - z*2n)) |
        (0xFFFFFFFFFFFFFn >> (z*2n))).toString();
$$;

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_FROMQUADKEY
(quadkey STRING)
RETURNS BIGINT
IMMUTABLE
AS $$
    IFF(quadkey IS NULL,
        NULL,
        CAST(@@SF_SCHEMA@@._QUADBIN_FROMQUADKEY(QUADKEY) AS BIGINT)
    )
$$;
