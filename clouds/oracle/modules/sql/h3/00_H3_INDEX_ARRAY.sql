----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Reset type idempotently. FORCE cascades to invalidate dependent
-- objects, which are recompiled when recreated later in the deploy.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.H3_INDEX_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TYPE @@ORA_SCHEMA@@.H3_INDEX_ARRAY AS TABLE OF VARCHAR2(16);
/
