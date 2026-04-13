----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@."__QUADBIN_INT_TOSTRING"
(value NUMBER)
RETURN VARCHAR2
AS
BEGIN
    IF value IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN LOWER(TO_CHAR(value, 'FM0XXXXXXXXXXXXXXX'));
END;
/
