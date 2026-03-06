----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_TOPARENT
(quadbin BIGINT, resolution INT)
RETURNS BIGINT
RETURN
IF(
    quadbin IS NULL OR resolution IS NULL
    OR resolution < 0 OR resolution > 26
    OR resolution > CAST((quadbin >> 52) & CAST(31 AS BIGINT) AS INT),
    NULL,
    (quadbin & ~SHIFTLEFT(CAST(31 AS BIGINT), 52))
    | SHIFTLEFT(CAST(resolution AS BIGINT), 52)
    | (SHIFTRIGHT(CAST(4503599627370495 AS BIGINT), resolution * 2))
);
