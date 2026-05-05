----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Private MLE binding to h3-js h3ToChildren.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_H3_TOCHILDREN_JS
(parent VARCHAR2, resolution NUMBER)
RETURN CLOB
AS MLE MODULE @@ORA_SCHEMA@@.h3_module
SIGNATURE 'toChildren(string, number)';
/

-- Pipelined wrapper. NULL inputs (or any error inside h3-js) yield an
-- empty pipeline.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_TOCHILDREN
(
    h3_index VARCHAR2, resolution NUMBER
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
DETERMINISTIC
AS
    v_cells CLOB;
BEGIN
    IF h3_index IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;

    v_cells := @@ORA_SCHEMA@@.INTERNAL_H3_TOCHILDREN_JS(h3_index, resolution);

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
