----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_TOPARENT
(quadbin BIGINT, resolution INT)
RETURNS BIGINT
RETURN
    IF(
        quadbin IS NULL OR resolution IS NULL
            OR resolution < 0 OR resolution > 26,
        NULL,
        (quadbin & ~shiftleft(CAST(31 AS BIGINT), 52))
            | shiftleft(CAST(resolution AS BIGINT), 52)
            | (shiftright(CAST(4503599627370495 AS BIGINT), resolution * 2))
    );
