----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_INT_TOSTRING
(
    h3_index NUMBER
)
RETURN VARCHAR2
DETERMINISTIC
IS
    HEX_FORMAT_MASK CONSTANT VARCHAR2(18) := 'FMXXXXXXXXXXXXXXXX';
    hex_result VARCHAR2(16);
BEGIN
    IF h3_index IS NULL THEN
        RETURN NULL;
    END IF;
    hex_result := LOWER(LTRIM(TO_CHAR(h3_index, HEX_FORMAT_MASK), '0'));
    IF hex_result IS NULL OR LENGTH(hex_result) = 0 THEN
        RETURN '0';
    END IF;
    RETURN hex_result;
END H3_INT_TOSTRING;
/
