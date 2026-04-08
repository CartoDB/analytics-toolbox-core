----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all quadbin cell indexes and their Chebyshev distances in a
-- filled square k-ring centered at the origin.
-- Each element is a JSON object: {"index": <quadbin>, "distance": <int>}.
--
-- Algorithm:
--   Same nested loop as QUADBIN_KRING but includes the Chebyshev distance
--   GREATEST(ABS(dx), ABS(dy)) for each neighbor.

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_KRING_DISTANCES
(origin NUMBER, distance NUMBER)
RETURN VARCHAR2
AS
    v_zxy    VARCHAR2(200);
    v_z      NUMBER;
    v_x      NUMBER;
    v_y      NUMBER;
    v_size   NUMBER;
    v_new_x  NUMBER;
    v_new_y  NUMBER;
    v_cheb   NUMBER;
    v_result VARCHAR2(32767);
    v_first  BOOLEAN := TRUE;
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

    v_result := '[';
    FOR v_dx IN -distance .. distance LOOP
        FOR v_dy IN -distance .. distance LOOP
            v_new_y := v_y + v_dy;

            -- Clip Y: skip if out of bounds
            IF v_new_y >= 0 AND v_new_y < v_size THEN
                -- Wrap X on the torus (adding v_size ensures positive modulo)
                v_new_x := MOD(v_x + v_dx + v_size, v_size);

                -- Chebyshev distance = max of absolute offsets
                v_cheb := GREATEST(ABS(v_dx), ABS(v_dy));

                IF v_first THEN
                    v_first := FALSE;
                ELSE
                    v_result := v_result || ',';
                END IF;

                v_result := v_result
                    || '{"index":'
                    || TO_CHAR(
                        @@ORA_SCHEMA@@.QUADBIN_FROMZXY(v_z, v_new_x, v_new_y)
                    )
                    || ',"distance":'
                    || TO_CHAR(v_cheb)
                    || '}';
            END IF;
        END LOOP;
    END LOOP;
    v_result := v_result || ']';

    RETURN v_result;
END;
/
