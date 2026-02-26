----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.ADD_ONE(n NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN n + 1;
END ADD_ONE;
/
