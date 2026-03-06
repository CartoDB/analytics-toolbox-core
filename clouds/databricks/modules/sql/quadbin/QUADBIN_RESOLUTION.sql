----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_RESOLUTION
(quadbin BIGINT)
RETURNS INT
RETURN
    CAST(shiftright(quadbin, 52) & 31 AS INT);
