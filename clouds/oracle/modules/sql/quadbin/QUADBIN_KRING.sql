----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all quadbin cell indexes in a filled square k-ring centered
-- at the origin.  Wraps around on the x-axis (torus); clips on the y-axis.
--
-- Algorithm:
--   1. Parse z/x/y from origin via QUADBIN_TOZXY
--   2. For dx from -distance to +distance:
--        For dy from -distance to +distance:
--          new_x = MOD(x + dx + 2^z, 2^z)   -- wrap on torus
--          new_y = y + dy
--          Skip if new_y < 0 or new_y >= 2^z  -- clip Y
--          Add QUADBIN_FROMZXY(z, new_x, new_y) to result
--   3. Return as JSON array

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_KRING
(origin NUMBER, distance NUMBER)
RETURN CLOB
AS
    v_zxy    VARCHAR2(200);
    v_z      NUMBER;
    v_x      NUMBER;
    v_y      NUMBER;
    v_size   NUMBER;
    v_new_x  NUMBER;
    v_new_y  NUMBER;
    v_result CLOB;
    v_first  BOOLEAN := TRUE;
    v_val    VARCHAR2(30);
BEGIN
    IF origin IS NULL OR distance IS NULL THEN
        RETURN NULL;
    END IF;

    -- Parse z/x/y from the JSON string returned by QUADBIN_TOZXY
    v_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(origin);
    v_z := TO_NUMBER(JSON_VALUE(v_zxy, '$.z'));
    v_x := TO_NUMBER(JSON_VALUE(v_zxy, '$.x'));
    v_y := TO_NUMBER(JSON_VALUE(v_zxy, '$.y'));

    -- Number of tiles per axis at this zoom level
    v_size := POWER(2, v_z);

    DBMS_LOB.CREATETEMPORARY(v_result, TRUE);
    DBMS_LOB.WRITEAPPEND(v_result, 1, '[');

    FOR v_dx IN -distance .. distance LOOP
        FOR v_dy IN -distance .. distance LOOP
            v_new_y := v_y + v_dy;

            -- Clip Y: skip if out of bounds
            IF v_new_y >= 0 AND v_new_y < v_size THEN
                -- Wrap X on the torus (adding v_size ensures positive modulo)
                v_new_x := MOD(v_x + v_dx + v_size, v_size);

                IF v_first THEN
                    v_first := FALSE;
                ELSE
                    DBMS_LOB.WRITEAPPEND(v_result, 1, ',');
                END IF;

                v_val := TO_CHAR(
                    @@ORA_SCHEMA@@.QUADBIN_FROMZXY(v_z, v_new_x, v_new_y)
                );
                DBMS_LOB.WRITEAPPEND(v_result, LENGTH(v_val), v_val);
            END IF;
        END LOOP;
    END LOOP;

    DBMS_LOB.WRITEAPPEND(v_result, 1, ']');
    RETURN v_result;
END;
/
