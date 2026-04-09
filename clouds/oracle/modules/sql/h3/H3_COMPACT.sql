----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_COMPACT
(
    h3_indexes VARCHAR2
)
RETURN VARCHAR2
DETERMINISTIC
IS
    -- Constants
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    HEX_CHILDREN_COUNT CONSTANT PLS_INTEGER := 7;
    PENTAGON_CHILDREN_COUNT CONSTANT PLS_INTEGER := 6;

    -- Collection types
    TYPE str_set IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(32);

    -- Working variables
    cells str_set;           -- current cell set (hex string -> 1)
    cell_key VARCHAR2(32);
    json_arr JSON_ARRAY_T;
    elem JSON_ELEMENT_T;
    cell_str VARCHAR2(32);
    i PLS_INTEGER;
    compacted BOOLEAN;

    -- Per-iteration variables
    TYPE parent_children_count IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(32);
    TYPE parent_child_list IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(32);
    parent_counts parent_children_count;
    parent_lists parent_child_list;
    parent_key VARCHAR2(32);
    parent_str VARCHAR2(32);
    cell_res PLS_INTEGER;
    expected_count PLS_INTEGER;
    is_pent NUMBER;
    child_list VARCHAR2(32767);
    child_str VARCHAR2(32);
    comma_pos PLS_INTEGER;

    -- Resolution tracking
    min_res PLS_INTEGER;
    max_res PLS_INTEGER;
    cur_res PLS_INTEGER;

    -- Result building
    json_result VARCHAR2(32767);
    first_entry BOOLEAN;

    -- Sorted output collection
    TYPE str_array IS TABLE OF VARCHAR2(32) INDEX BY PLS_INTEGER;
    sorted_cells str_array;
    sorted_count PLS_INTEGER;
BEGIN
    -- Handle NULL input
    IF h3_indexes IS NULL THEN
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

    -- Load cells into associative array (deduplicates automatically)
    FOR i IN 0 .. json_arr.GET_SIZE() - 1 LOOP
        elem := json_arr.GET(i);
        cell_str := LOWER(TRIM(REPLACE(elem.TO_STRING(), '"', '')));
        IF cell_str IS NOT NULL AND LENGTH(cell_str) > 0 THEN
            cells(cell_str) := 1;
        END IF;
    END LOOP;

    IF cells.COUNT = 0 THEN
        RETURN '[]';
    END IF;

    -- Iterative compaction: repeat until no more compaction is possible
    compacted := TRUE;
    WHILE compacted LOOP
        compacted := FALSE;

        -- Find the resolution range of current cells
        min_res := MAX_RESOLUTION;
        max_res := MIN_RESOLUTION;
        cell_key := cells.FIRST;
        WHILE cell_key IS NOT NULL LOOP
            cell_res := @@ORA_SCHEMA@@.H3_RESOLUTION(cell_key);
            IF cell_res IS NOT NULL THEN
                IF cell_res < min_res THEN
                    min_res := cell_res;
                END IF;
                IF cell_res > max_res THEN
                    max_res := cell_res;
                END IF;
            END IF;
            cell_key := cells.NEXT(cell_key);
        END LOOP;

        -- Process from finest to coarsest resolution
        FOR cur_res IN REVERSE min_res .. max_res LOOP
            -- Skip resolution 0 -- cannot compact further
            IF cur_res > MIN_RESOLUTION THEN
                -- Group cells at this resolution by parent
                parent_counts.DELETE;
                parent_lists.DELETE;

                cell_key := cells.FIRST;
                WHILE cell_key IS NOT NULL LOOP
                    cell_res := @@ORA_SCHEMA@@.H3_RESOLUTION(cell_key);
                    IF cell_res = cur_res THEN
                        parent_str := @@ORA_SCHEMA@@.H3_TOPARENT(
                            cell_key, cur_res - 1
                        );
                        IF parent_str IS NOT NULL THEN
                            IF parent_counts.EXISTS(parent_str) THEN
                                parent_counts(parent_str) :=
                                    parent_counts(parent_str) + 1;
                                parent_lists(parent_str) :=
                                    parent_lists(parent_str)
                                    || ',' || cell_key;
                            ELSE
                                parent_counts(parent_str) := 1;
                                parent_lists(parent_str) := cell_key;
                            END IF;
                        END IF;
                    END IF;
                    cell_key := cells.NEXT(cell_key);
                END LOOP;

                -- Check each parent to see if all children are present
                parent_key := parent_counts.FIRST;
                WHILE parent_key IS NOT NULL LOOP
                    is_pent := @@ORA_SCHEMA@@.H3_ISPENTAGON(parent_key);
                    IF is_pent = 1 THEN
                        expected_count := PENTAGON_CHILDREN_COUNT;
                    ELSE
                        expected_count := HEX_CHILDREN_COUNT;
                    END IF;

                    IF parent_counts(parent_key) = expected_count THEN
                        -- Replace all children with the parent
                        compacted := TRUE;
                        child_list := parent_lists(parent_key);

                        -- Remove each child from the cell set
                        LOOP
                            comma_pos := INSTR(child_list, ',');
                            IF comma_pos > 0 THEN
                                child_str := SUBSTR(
                                    child_list, 1, comma_pos - 1
                                );
                                child_list := SUBSTR(
                                    child_list, comma_pos + 1
                                );
                            ELSE
                                child_str := child_list;
                                child_list := NULL;
                            END IF;

                            IF cells.EXISTS(child_str) THEN
                                cells.DELETE(child_str);
                            END IF;

                            EXIT WHEN child_list IS NULL
                                OR LENGTH(child_list) = 0;
                        END LOOP;

                        -- Add the parent
                        cells(parent_key) := 1;
                    END IF;

                    parent_key := parent_counts.NEXT(parent_key);
                END LOOP;
            END IF;
        END LOOP;
    END LOOP;

    -- Collect cells into an indexable array for sorting
    sorted_count := 0;
    cell_key := cells.FIRST;
    WHILE cell_key IS NOT NULL LOOP
        sorted_count := sorted_count + 1;
        sorted_cells(sorted_count) := cell_key;
        cell_key := cells.NEXT(cell_key);
    END LOOP;

    -- The associative array keyed by VARCHAR2 is already iterated
    -- in key order, so sorted_cells is already sorted lexicographically.

    -- Build JSON array result
    json_result := '[';
    first_entry := TRUE;
    FOR i IN 1 .. sorted_count LOOP
        IF first_entry THEN
            first_entry := FALSE;
        ELSE
            json_result := json_result || ',';
        END IF;
        json_result := json_result || '"' || sorted_cells(i) || '"';
    END LOOP;
    json_result := json_result || ']';

    RETURN json_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN '[]';
END H3_COMPACT;
/
