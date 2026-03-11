----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Converts a quadbin index to a quadkey string.
-- Uses Python UDF because base-4 string formatting has no clean
-- pure SQL equivalent (BigQuery also uses JavaScript for this).

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_TOQUADKEY
(quadbin BIGINT)
RETURNS STRING
LANGUAGE PYTHON
AS $$
import numpy as np

if quadbin is None:
    return None

z = (quadbin >> 52) & 0x1F
xy = (quadbin & 0xFFFFFFFFFFFFF) >> (52 - z * 2)

if z == 0:
    return ''

return np.base_repr(int(xy), base=4).zfill(z)
$$;
