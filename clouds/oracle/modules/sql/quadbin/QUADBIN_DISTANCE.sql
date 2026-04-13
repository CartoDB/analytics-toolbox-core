----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the Chebyshev distance between two quadbin indexes.
-- Both must have the same resolution; otherwise returns NULL.
--
-- Algorithm:
--   1. Parse z/x/y from both quadbins via QUADBIN_TOZXY
--   2. If resolutions differ, return NULL
--   3. Return GREATEST(ABS(x_a - x_b), ABS(y_a - y_b))

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_DISTANCE
(origin NUMBER, destination NUMBER)
RETURN NUMBER
AS
    v_o_zxy VARCHAR2(200);
    v_d_zxy VARCHAR2(200);
    v_o_z   NUMBER;
    v_o_x   NUMBER;
    v_o_y   NUMBER;
    v_d_z   NUMBER;
    v_d_x   NUMBER;
    v_d_y   NUMBER;
BEGIN
    IF origin IS NULL OR destination IS NULL THEN
        RETURN NULL;
    END IF;

    -- Parse z/x/y from both quadbins
    v_o_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(origin);
    v_o_z := TO_NUMBER(JSON_VALUE(v_o_zxy, '$.z'));
    v_o_x := TO_NUMBER(JSON_VALUE(v_o_zxy, '$.x'));
    v_o_y := TO_NUMBER(JSON_VALUE(v_o_zxy, '$.y'));

    v_d_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(destination);
    v_d_z := TO_NUMBER(JSON_VALUE(v_d_zxy, '$.z'));
    v_d_x := TO_NUMBER(JSON_VALUE(v_d_zxy, '$.x'));
    v_d_y := TO_NUMBER(JSON_VALUE(v_d_zxy, '$.y'));

    -- Different resolutions: return NULL
    IF v_o_z != v_d_z THEN
        RETURN NULL;
    END IF;

    -- Chebyshev distance
    RETURN GREATEST(ABS(v_d_x - v_o_x), ABS(v_d_y - v_o_y));
END;
/
