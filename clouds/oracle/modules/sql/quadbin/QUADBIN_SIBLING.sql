----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the adjacent quadbin in a given direction (left/right/up/down).
-- Wraps around on the x-axis (torus); returns NULL if the sibling is
-- out of bounds on the y-axis [0, 2^z).
--
-- Algorithm:
--   1. Parse z/x/y from QUADBIN_TOZXY
--   2. Apply direction delta: left dx=-1, right dx=+1, up dy=-1, down dy=+1
--   3. Wrap new_x on the torus: MOD(x + dx + 2^z, 2^z)
--   4. Clip new_y: return NULL if out of [0, 2^z)
--   5. Return QUADBIN_FROMZXY(z, new_x, new_y)

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_SIBLING
(quadbin NUMBER, direction VARCHAR2)
RETURN NUMBER
AS
    v_zxy    @@ORA_SCHEMA@@.QUADBIN_ZXY;
    v_z      NUMBER;
    v_x      NUMBER;
    v_y      NUMBER;
    v_dx     NUMBER;
    v_dy     NUMBER;
    v_size   NUMBER;
    v_new_x  NUMBER;
    v_new_y  NUMBER;
BEGIN
    IF quadbin IS NULL OR direction IS NULL THEN
        RETURN NULL;
    END IF;

    IF direction NOT IN ('left', 'right', 'up', 'down') THEN
        RAISE_APPLICATION_ERROR(
            -20001, 'Wrong direction argument passed to sibling'
        );
    END IF;

    v_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(quadbin);
    v_z := v_zxy.z;
    v_x := v_zxy.x;
    v_y := v_zxy.y;

    -- Direction deltas
    CASE direction
        WHEN 'left'  THEN v_dx := -1; v_dy := 0;
        WHEN 'right' THEN v_dx :=  1; v_dy := 0;
        WHEN 'up'    THEN v_dx :=  0; v_dy := -1;
        WHEN 'down'  THEN v_dx :=  0; v_dy :=  1;
    END CASE;

    -- Number of tiles per axis at this zoom level
    v_size := POWER(2, v_z);

    -- Wrap x on the torus (adding v_size ensures positive modulo)
    v_new_x := MOD(v_x + v_dx + v_size, v_size);

    -- Clip y: return NULL if out of bounds
    v_new_y := v_y + v_dy;
    IF v_new_y < 0 OR v_new_y >= v_size THEN
        RETURN NULL;
    END IF;

    RETURN @@ORA_SCHEMA@@.QUADBIN_FROMZXY(v_z, v_new_x, v_new_y);
END;
/
