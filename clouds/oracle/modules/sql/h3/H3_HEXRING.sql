----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Private MLE binding to h3-js hexRing.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_H3_HEXRING_JS
(origin VARCHAR2, k NUMBER)
RETURN CLOB
AS MLE MODULE @@ORA_SCHEMA@@.h3_module
SIGNATURE 'hexring(string, number)';
/

-- Pipelined wrapper. h3-js hexRing throws when the ring crosses pentagon
-- distortion; the JS module catches that and returns '[]', so callers
-- get an empty pipeline (matches BQ/SF behaviour).
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_HEXRING
(
    origin VARCHAR2, distance NUMBER
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
AS
    v_cells CLOB;
BEGIN
    IF origin IS NULL OR distance IS NULL THEN
        RETURN;
    END IF;

    v_cells := @@ORA_SCHEMA@@.INTERNAL_H3_HEXRING_JS(origin, distance);

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
