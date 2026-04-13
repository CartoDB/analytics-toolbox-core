----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_UNCOMPACT
(
    h3_indexes VARCHAR2, resolution NUMBER
)
RETURN VARCHAR2
DETERMINISTIC
IS
    -- Constants
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;

    -- Collection types
    TYPE str_set IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(32);

    -- Working variables
    result_cells str_set;    -- deduplicated result set
    json_arr JSON_ARRAY_T;
    children_arr JSON_ARRAY_T;
    elem JSON_ELEMENT_T;
    cell_str VARCHAR2(32);
    child_str VARCHAR2(32);
    children_json VARCHAR2(32767);
    cell_res PLS_INTEGER;
    target_res PLS_INTEGER;
    i PLS_INTEGER;
    j PLS_INTEGER;

    -- Result building
    json_result VARCHAR2(32767);
    first_entry BOOLEAN;
    cell_key VARCHAR2(32);
BEGIN
    -- Handle NULL inputs
    IF h3_indexes IS NULL OR resolution IS NULL THEN
        RETURN '[]';
    END IF;

    target_res := TRUNC(resolution);
    IF target_res < MIN_RESOLUTION OR target_res > MAX_RESOLUTION THEN
        RETURN '[]';
    END IF;

    -- Parse JSON array
    BEGIN
        json_arr := JSON_ARRAY_T.PARSE(h3_indexes);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN '[]';
    END;

    IF json_arr.GET_SIZE() = 0 THEN
        RETURN '[]';
    END IF;

    -- Process each cell
    FOR i IN 0 .. json_arr.GET_SIZE() - 1 LOOP
        elem := json_arr.GET(i);
        cell_str := LOWER(TRIM(REPLACE(elem.TO_STRING(), '"', '')));

        IF cell_str IS NOT NULL AND LENGTH(cell_str) > 0 THEN
            cell_res := @@ORA_SCHEMA@@.H3_RESOLUTION(cell_str);

            IF cell_res IS NOT NULL THEN
                IF cell_res = target_res THEN
                    -- Already at target resolution, keep as-is
                    result_cells(cell_str) := 1;
                ELSIF cell_res < target_res THEN
                    -- Expand to target resolution using H3_TOCHILDREN
                    children_json := @@ORA_SCHEMA@@.H3_TOCHILDREN(
                        cell_str, target_res
                    );
                    IF children_json IS NOT NULL
                        AND children_json <> '[]'
                    THEN
                        BEGIN
                            children_arr := JSON_ARRAY_T.PARSE(
                                children_json
                            );
                            FOR j IN 0 .. children_arr.GET_SIZE() - 1
                            LOOP
                                child_str := LOWER(TRIM(REPLACE(
                                    children_arr.GET(j).TO_STRING(),
                                    '"', ''
                                )));
                                IF child_str IS NOT NULL
                                    AND LENGTH(child_str) > 0
                                THEN
                                    result_cells(child_str) := 1;
                                END IF;
                            END LOOP;
                        EXCEPTION
                            WHEN OTHERS THEN
                                NULL;  -- skip malformed children
                        END;
                    END IF;
                END IF;
                -- cell_res > target_res: skip (finer than target)
            END IF;
        END IF;
    END LOOP;

    IF result_cells.COUNT = 0 THEN
        RETURN '[]';
    END IF;

    -- Build sorted JSON array result
    -- Associative array keyed by VARCHAR2 iterates in key order
    json_result := '[';
    first_entry := TRUE;
    cell_key := result_cells.FIRST;
    WHILE cell_key IS NOT NULL LOOP
        IF first_entry THEN
            first_entry := FALSE;
        ELSE
            json_result := json_result || ',';
        END IF;
        json_result := json_result || '"' || cell_key || '"';
        cell_key := result_cells.NEXT(cell_key);
    END LOOP;
    json_result := json_result || ']';

    RETURN json_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '[]';
END H3_UNCOMPACT;
/
