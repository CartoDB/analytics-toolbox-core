----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_TOPARENT
(
    h3_index VARCHAR2, resolution NUMBER
)
RETURN VARCHAR2
DETERMINISTIC
IS
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    h3_raw RAW(8);
    is_valid BOOLEAN;
    current_resolution PLS_INTEGER;
    parent_raw RAW(8);
BEGIN
    IF h3_index IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;
    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RETURN NULL;
    END IF;
    h3_raw := HEXTORAW(LPAD(h3_index, RAW_BYTE_LENGTH, '0'));
    is_valid := SDO_UTIL.H3_IS_VALID_CELL(h3_raw);
    IF NOT is_valid THEN
        RETURN NULL;
    END IF;
    current_resolution := SDO_UTIL.H3_RESOLUTION(h3_raw);
    IF resolution >= current_resolution THEN
        RETURN NULL;
    END IF;
    parent_raw := SDO_UTIL.H3_PARENT(h3_raw, resolution);
    RETURN LOWER(LTRIM(RAWTOHEX(parent_raw), '0'));
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END H3_TOPARENT;
/
