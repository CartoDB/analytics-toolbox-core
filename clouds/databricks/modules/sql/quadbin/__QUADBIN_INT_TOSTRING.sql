----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.__QUADBIN_INT_TOSTRING
(quadbin BIGINT)
RETURNS STRING
RETURN
    LPAD(HEX(quadbin), 16, '0');
