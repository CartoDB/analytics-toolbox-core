----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_CENTER
(
    h3_index VARCHAR2
)
RETURN SDO_GEOMETRY
DETERMINISTIC
IS
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    h3_raw RAW(8);
    is_valid BOOLEAN;
BEGIN
    IF h3_index IS NULL THEN
        RETURN NULL;
    END IF;
    h3_raw := HEXTORAW(LPAD(h3_index, RAW_BYTE_LENGTH, '0'));
    is_valid := SDO_UTIL.H3_IS_VALID_CELL(h3_raw);
    IF NOT is_valid THEN
        RETURN NULL;
    END IF;
    RETURN SDO_UTIL.H3_CENTER(h3_raw);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END H3_CENTER;
/
