----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_UNCOMPACT
(
    h3_indexes @@ORA_SCHEMA@@.H3_INDEX_ARRAY, resolution NUMBER
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
DETERMINISTIC
IS
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;

    TYPE str_set IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(32);

    result_cells str_set;
    cell_str VARCHAR2(32);
    cell_res PLS_INTEGER;
    target_res PLS_INTEGER;
    cell_key VARCHAR2(32);
    i PLS_INTEGER;
BEGIN
    IF h3_indexes IS NULL OR h3_indexes.COUNT = 0 OR resolution IS NULL THEN
        RETURN;
    END IF;

    target_res := TRUNC(resolution);
    IF target_res < MIN_RESOLUTION OR target_res > MAX_RESOLUTION THEN
        RETURN;
    END IF;

    FOR i IN 1 .. h3_indexes.COUNT LOOP
        cell_str := LOWER(TRIM(h3_indexes(i)));

        IF cell_str IS NOT NULL AND LENGTH(cell_str) > 0 THEN
            cell_res := @@ORA_SCHEMA@@.H3_RESOLUTION(cell_str);

            IF cell_res IS NOT NULL THEN
                IF cell_res = target_res THEN
                    result_cells(cell_str) := 1;
                ELSIF cell_res < target_res THEN
                    -- Expand to target resolution via pipelined H3_TOCHILDREN
                    FOR child_rec IN (
                        SELECT COLUMN_VALUE AS h3
                        FROM TABLE(@@ORA_SCHEMA@@.H3_TOCHILDREN(
                            cell_str, target_res
                        ))
                    ) LOOP
                        IF child_rec.h3 IS NOT NULL
                            AND LENGTH(child_rec.h3) > 0
                        THEN
                            result_cells(child_rec.h3) := 1;
                        END IF;
                    END LOOP;
                END IF;
                -- cell_res > target_res: skip (finer than target)
            END IF;
        END IF;
    END LOOP;

    -- Pipe out cells in associative-array key order (lexicographic)
    cell_key := result_cells.FIRST;
    WHILE cell_key IS NOT NULL LOOP
        PIPE ROW(cell_key);
        cell_key := result_cells.NEXT(cell_key);
    END LOOP;

    RETURN;
EXCEPTION
    WHEN NO_DATA_NEEDED THEN
        RETURN;
    WHEN OTHERS THEN
        RETURN;
END H3_UNCOMPACT;
/
