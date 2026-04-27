----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_COMPACT
(
    h3_indexes @@ORA_SCHEMA@@.H3_INDEX_ARRAY
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
DETERMINISTIC
IS
    -- Constants
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    HEX_CHILDREN_COUNT CONSTANT PLS_INTEGER := 7;
    PENTAGON_CHILDREN_COUNT CONSTANT PLS_INTEGER := 6;

    -- Collection types
    TYPE str_set IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(32);

    -- Working variables
    cells str_set;
    cell_key VARCHAR2(32);
    cell_str VARCHAR2(32);
    compacted BOOLEAN;

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

    min_res PLS_INTEGER;
    max_res PLS_INTEGER;
    cur_res PLS_INTEGER;

    i PLS_INTEGER;
BEGIN
    IF h3_indexes IS NULL OR h3_indexes.COUNT = 0 THEN
        RETURN;
    END IF;

    -- Load input cells into associative array (deduplicates automatically,
    -- iterates in lexicographic key order)
    FOR i IN 1 .. h3_indexes.COUNT LOOP
        cell_str := LOWER(TRIM(h3_indexes(i)));
        IF cell_str IS NOT NULL AND LENGTH(cell_str) > 0 THEN
            cells(cell_str) := 1;
        END IF;
    END LOOP;

    IF cells.COUNT = 0 THEN
        RETURN;
    END IF;

    -- Iterative compaction: repeat until no more compaction is possible
    compacted := TRUE;
    WHILE compacted LOOP
        compacted := FALSE;

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

        FOR cur_res IN REVERSE min_res .. max_res LOOP
            IF cur_res > MIN_RESOLUTION THEN
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

                parent_key := parent_counts.FIRST;
                WHILE parent_key IS NOT NULL LOOP
                    is_pent := @@ORA_SCHEMA@@.H3_ISPENTAGON(parent_key);
                    IF is_pent = 1 THEN
                        expected_count := PENTAGON_CHILDREN_COUNT;
                    ELSE
                        expected_count := HEX_CHILDREN_COUNT;
                    END IF;

                    IF parent_counts(parent_key) = expected_count THEN
                        compacted := TRUE;
                        child_list := parent_lists(parent_key);

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

                        cells(parent_key) := 1;
                    END IF;

                    parent_key := parent_counts.NEXT(parent_key);
                END LOOP;
            END IF;
        END LOOP;
    END LOOP;

    -- Pipe out cells in associative-array key order (lexicographic)
    cell_key := cells.FIRST;
    WHILE cell_key IS NOT NULL LOOP
        PIPE ROW(cell_key);
        cell_key := cells.NEXT(cell_key);
    END LOOP;

    RETURN;
EXCEPTION
    WHEN NO_DATA_NEEDED THEN
        RETURN;
    WHEN OTHERS THEN
        RETURN;
END H3_COMPACT;
/
