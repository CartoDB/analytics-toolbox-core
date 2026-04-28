----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Types used by this function. Inline declaration with idempotent DROP+CREATE.
-- Drop in reverse-dependency order (DISTANCE_ARRAY references DISTANCE_PAIR).
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
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
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR AS OBJECT (
    quadbin_index NUMBER,
    distance      NUMBER
);
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_ARRAY
    AS TABLE OF @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR;
/

-- Returns all quadbin cell indexes and their Chebyshev distances in a
-- filled square k-ring centered at the origin, as a pipelined collection
-- of QUADBIN_DISTANCE_PAIR (quadbin_index, distance).
--
-- Consume via:
--   SELECT t.quadbin_index, t.distance
--   FROM TABLE(QUADBIN_KRING_DISTANCES(idx, k)) t;
--
-- Same nested loop as QUADBIN_KRING, but each row also carries the
-- Chebyshev distance GREATEST(ABS(dx), ABS(dy)).

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES
(origin NUMBER, distance NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_DISTANCE_ARRAY PIPELINED
AS
    v_zxy    @@ORA_SCHEMA@@.QUADBIN_ZXY;
    v_z      NUMBER;
    v_x      NUMBER;
    v_y      NUMBER;
    v_size   NUMBER;
    v_new_x  NUMBER;
    v_new_y  NUMBER;
    v_cheb   NUMBER;
BEGIN
    IF origin IS NULL OR distance IS NULL THEN
        RETURN;
    END IF;

    v_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(origin);
    v_z := v_zxy.z;
    v_x := v_zxy.x;
    v_y := v_zxy.y;

    v_size := POWER(2, v_z);

    FOR v_dx IN -distance .. distance LOOP
        FOR v_dy IN -distance .. distance LOOP
            v_new_y := v_y + v_dy;

            IF v_new_y >= 0 AND v_new_y < v_size THEN
                v_new_x := MOD(v_x + v_dx + v_size, v_size);
                v_cheb := GREATEST(ABS(v_dx), ABS(v_dy));
                PIPE ROW(@@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR(
                    @@ORA_SCHEMA@@.QUADBIN_FROMZXY(v_z, v_new_x, v_new_y),
                    v_cheb
                ));
            END IF;
        END LOOP;
    END LOOP;

    RETURN;
END;
/
