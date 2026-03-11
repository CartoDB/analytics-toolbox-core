----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts a quadkey string to a quadbin index.
-- Uses Python UDF because base-4 string parsing has no clean
-- pure SQL equivalent (BigQuery also uses JavaScript for this).

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_FROMQUADKEY
(quadkey STRING)
RETURNS BIGINT
LANGUAGE PYTHON
AS $$
if quadkey is None:
    return None

HEADER = 0x4000000000000000
MODE_BIT = 1 << 59

z = len(quadkey)
xy = int(quadkey, 4) if z > 0 else 0
unused_bits = (1 << (52 - z * 2)) - 1

return HEADER | MODE_BIT | (z << 52) | (xy << (52 - z * 2)) | unused_bits
$$;
