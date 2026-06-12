----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_RESOLUTION
(quadbin NUMBER)
RETURN NUMBER
AS
BEGIN
    IF quadbin IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN BITAND(TRUNC(quadbin / POWER(2, 52)), 31);
END;
/
