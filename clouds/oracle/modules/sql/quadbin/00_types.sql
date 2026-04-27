----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Module-scoped types for the Oracle Quadbin module. Types are deployed
-- before any function file thanks to the `00_` prefix (alphabetical order).
--
-- Naming convention (per .claude/rules/oracle.md):
--   <MODULE>_<NAME>      OBJECT type
--   <MODULE>_<NAME>_ARRAY  TABLE OF <object>  (PIPELINED collection)
--
-- `QUADBIN_BBOX` already names a function, and Oracle types share the
-- function namespace, so the bbox object uses the `_OBJ` suffix.
--
-- Idempotency: Oracle has no "DROP TYPE IF EXISTS"; the BEGIN/EXCEPTION
-- block is the canonical idiom. FORCE cascades to dependent objects so
-- redeploys recompile rather than fail with ORA-02303.

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_BBOX_OBJ FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_ZXY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Tile coordinates returned by QUADBIN_TOZXY.
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_ZXY AS OBJECT (
    z NUMBER,
    x NUMBER,
    y NUMBER
);
/

-- Geographic bounding box (WGS84 degrees) returned by QUADBIN_BBOX.
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_BBOX_OBJ AS OBJECT (
    west  BINARY_DOUBLE,
    south BINARY_DOUBLE,
    east  BINARY_DOUBLE,
    north BINARY_DOUBLE
);
/

-- Collection of quadbin indices, returned by QUADBIN_KRING,
-- QUADBIN_TOCHILDREN, QUADBIN_POLYFILL via PIPE ROW.
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY AS TABLE OF NUMBER;
/

-- (index, distance) pair element of QUADBIN_KRING_DISTANCES output.
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR AS OBJECT (
    quadbin_index NUMBER,
    distance      NUMBER
);
/

CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_ARRAY
    AS TABLE OF @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR;
/
