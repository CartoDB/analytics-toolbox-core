----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Private MLE binding to h3-js h3Distance. The JS wrapper returns null
-- for unreachable pairs (different resolutions, far across pentagon
-- distortion); PL/SQL surfaces that as NULL.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.INTERNAL_H3_DISTANCE_JS
(origin VARCHAR2, destination VARCHAR2)
RETURN NUMBER
AS MLE MODULE @@ORA_SCHEMA@@.h3_module
SIGNATURE 'distance(string, string)';
/

-- Public wrapper.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_DISTANCE
(
    origin VARCHAR2, destination VARCHAR2
)
RETURN NUMBER
DETERMINISTIC
AS
BEGIN
    IF origin IS NULL OR destination IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN @@ORA_SCHEMA@@.INTERNAL_H3_DISTANCE_JS(origin, destination);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/
