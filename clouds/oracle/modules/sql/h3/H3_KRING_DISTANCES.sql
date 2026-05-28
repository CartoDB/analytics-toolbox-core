----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Private MLE binding to h3-js kRingDistances. JS returns a JSON array
-- of {h3, distance} objects.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_H3_KRING_DISTANCES_JS
(origin VARCHAR2, k NUMBER)
RETURN CLOB
AS MLE MODULE @@ORA_SCHEMA@@.h3_module
SIGNATURE 'kringDistances(string, number)';
/

-- Pipelined wrapper. NULL inputs yield an empty pipeline.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_KRING_DISTANCES
(
    origin VARCHAR2, distance NUMBER
)
RETURN @@ORA_SCHEMA@@.H3_DISTANCE_ARRAY PIPELINED
AS
    v_pairs CLOB;
BEGIN
    IF origin IS NULL OR distance IS NULL THEN
        RETURN;
    END IF;

    v_pairs := @@ORA_SCHEMA@@.INTERNAL_H3_KRING_DISTANCES_JS(origin, distance);

    FOR rec IN (
        SELECT jt.h3, jt.distance
        FROM JSON_TABLE(
            v_pairs, '$[*]'
            COLUMNS (
                h3       VARCHAR2(16) PATH '$.h3',
                distance NUMBER       PATH '$.distance'
            )
        ) jt
    ) LOOP
        PIPE ROW(@@ORA_SCHEMA@@.H3_DISTANCE_PAIR(rec.h3, rec.distance));
    END LOOP;

    RETURN;
END;
/
