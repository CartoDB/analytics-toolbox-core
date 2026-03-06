----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.__QUADBIN_STRING_TOINT
(quadbin STRING)
RETURNS BIGINT
RETURN
    CONV(quadbin, 16, 10);
