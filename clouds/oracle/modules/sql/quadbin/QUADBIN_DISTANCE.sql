----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Type used by this function. Inline declaration with idempotent DROP+CREATE.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_ZXY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_ZXY AS OBJECT (
    z NUMBER,
    x NUMBER,
    y NUMBER
);
/

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
    v_o_zxy @@ORA_SCHEMA@@.QUADBIN_ZXY;
    v_d_zxy @@ORA_SCHEMA@@.QUADBIN_ZXY;
BEGIN
    IF origin IS NULL OR destination IS NULL THEN
        RETURN NULL;
    END IF;

    v_o_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(origin);
    v_d_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(destination);

    -- Different resolutions: return NULL
    IF v_o_zxy.z != v_d_zxy.z THEN
        RETURN NULL;
    END IF;

    -- Chebyshev distance
    RETURN GREATEST(ABS(v_d_zxy.x - v_o_zxy.x), ABS(v_d_zxy.y - v_o_zxy.y));
END;
/
