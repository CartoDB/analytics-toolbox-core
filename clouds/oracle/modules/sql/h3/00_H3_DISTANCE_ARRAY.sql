----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Reset types idempotently in reverse-dependency order (collection
-- depends on element type, so drop the collection first). FORCE
-- cascades to invalidate dependent objects, which are recompiled
-- when recreated later in the deploy.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.H3_DISTANCE_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.H3_DISTANCE_PAIR FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TYPE @@ORA_SCHEMA@@.H3_DISTANCE_PAIR AS OBJECT (
    h3 VARCHAR2(16),
    distance NUMBER
);
/

CREATE TYPE @@ORA_SCHEMA@@.H3_DISTANCE_ARRAY
    AS TABLE OF @@ORA_SCHEMA@@.H3_DISTANCE_PAIR;
/
