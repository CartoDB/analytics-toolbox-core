----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.SUM_RANGE(start_num NUMBER, end_num NUMBER)
RETURN NUMBER
IS
    total NUMBER := 0;
    current_num NUMBER;
BEGIN
    current_num := start_num;
    WHILE current_num <= end_num LOOP
        -- Use ADD_ONE to increment (demonstrates dependency on ADD_ONE)
        total := total + current_num;
        current_num := @@ORA_SCHEMA@@.ADD_ONE(current_num);
    END LOOP;
    RETURN total;
END SUM_RANGE;
/
