----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_FROMQUADKEY
(quadkey VARCHAR(MAX))
RETURNS BIGINT
STABLE
AS $$
    z = len(quadkey)
    xy = int(quadkey or '0', 4)
    return (
        0x4000000000000000 |
        (1 << 59) |
        (z << 52) |
        (xy << (52 - z * 2)) |
        (0xFFFFFFFFFFFFF >> (z * 2))
    )
$$ LANGUAGE plpythonu;
