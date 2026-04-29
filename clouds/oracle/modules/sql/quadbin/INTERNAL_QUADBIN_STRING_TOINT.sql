----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_QUADBIN_STRING_TOINT
(value VARCHAR2)
RETURN NUMBER
AS
BEGIN
    IF value IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN TO_NUMBER(value, 'XXXXXXXXXXXXXXXX');
END;
/
