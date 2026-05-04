----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Private MLE binding to h3-js compact. Input is a JSON array string.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_H3_COMPACT_JS
(cells_json CLOB)
RETURN CLOB
AS MLE MODULE @@ORA_SCHEMA@@.h3_module
SIGNATURE 'compact(string)';
/

-- Pipelined wrapper. Marshals the H3_INDEX_ARRAY into a JSON array,
-- calls the JS export, then pipes each returned cell. NULL or empty
-- input yields an empty pipeline.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_COMPACT
(
    h3_indexes @@ORA_SCHEMA@@.H3_INDEX_ARRAY
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
DETERMINISTIC
AS
    v_input  CLOB;
    v_cells  CLOB;
BEGIN
    IF h3_indexes IS NULL OR h3_indexes.COUNT = 0 THEN
        RETURN;
    END IF;

    -- Marshal the nested table to a JSON array
    SELECT JSON_ARRAYAGG(COLUMN_VALUE)
      INTO v_input
      FROM TABLE(h3_indexes);

    v_cells := @@ORA_SCHEMA@@.INTERNAL_H3_COMPACT_JS(v_input);

    FOR rec IN (
        SELECT jt.cell AS h3
        FROM JSON_TABLE(
            v_cells, '$[*]'
            COLUMNS (cell VARCHAR2(16) PATH '$')
        ) jt
    ) LOOP
        PIPE ROW(rec.h3);
    END LOOP;

    RETURN;
END;
/
