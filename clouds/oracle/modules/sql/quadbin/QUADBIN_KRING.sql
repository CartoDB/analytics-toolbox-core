----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all quadbin cell indexes in a filled square k-ring centered
-- at the origin, as a pipelined collection (QUADBIN_INDEX_ARRAY). Wraps
-- around on the x-axis (torus); clips on the y-axis.
--
-- Consume via: SELECT COLUMN_VALUE FROM TABLE(QUADBIN_KRING(idx, k))
--
-- Algorithm:
--   1. Parse z/x/y from origin via QUADBIN_TOZXY
--   2. For dx in [-distance, distance], dy in [-distance, distance]:
--        new_x = MOD(x + dx + 2^z, 2^z)   -- wrap on torus
--        new_y = y + dy
--        Skip if new_y < 0 or new_y >= 2^z  -- clip Y
--        PIPE ROW(QUADBIN_FROMZXY(z, new_x, new_y))
--
-- NULL inputs: returns an empty pipeline (TABLE(...) yields no rows).

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_KRING
(origin NUMBER, distance NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    v_zxy    @@ORA_SCHEMA@@.QUADBIN_ZXY;
    v_z      NUMBER;
    v_x      NUMBER;
    v_y      NUMBER;
    v_size   NUMBER;
    v_new_x  NUMBER;
    v_new_y  NUMBER;
BEGIN
    IF origin IS NULL OR distance IS NULL THEN
        RETURN;
    END IF;

    v_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(origin);
    v_z := v_zxy.z;
    v_x := v_zxy.x;
    v_y := v_zxy.y;

    -- Number of tiles per axis at this zoom level
    v_size := POWER(2, v_z);

    FOR v_dx IN -distance .. distance LOOP
        FOR v_dy IN -distance .. distance LOOP
            v_new_y := v_y + v_dy;

            -- Clip Y: skip if out of bounds
            IF v_new_y >= 0 AND v_new_y < v_size THEN
                -- Wrap X on the torus (adding v_size ensures positive modulo)
                v_new_x := MOD(v_x + v_dx + v_size, v_size);
                PIPE ROW(@@ORA_SCHEMA@@.QUADBIN_FROMZXY(v_z, v_new_x, v_new_y));
            END IF;
        END LOOP;
    END LOOP;

    RETURN;
END;
/
