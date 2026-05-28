----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_ISPENTAGON
(
    h3_index VARCHAR2
)
RETURN NUMBER
DETERMINISTIC
IS
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    h3_raw RAW(8);
    is_valid BOOLEAN;
    is_pentagon BOOLEAN;
BEGIN
    IF h3_index IS NULL THEN
        RETURN 0;
    END IF;
    h3_raw := HEXTORAW(LPAD(h3_index, RAW_BYTE_LENGTH, '0'));
    is_valid := SDO_UTIL.H3_IS_VALID_CELL(h3_raw);
    IF NOT is_valid THEN
        RETURN 0;
    END IF;
    is_pentagon := SDO_UTIL.H3_IS_PENTAGON(h3_raw);
    IF is_pentagon THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END H3_ISPENTAGON;
/
