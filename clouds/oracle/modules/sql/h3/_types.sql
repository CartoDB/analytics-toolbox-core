----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Shared types for the h3 module. Single source of truth — referenced
-- by every H3_* function that uses a custom type. Deploy ordering is
-- handled automatically by build_modules.js dependency detection.
--
-- Each type is paired (drop + create) so adding a new type means inserting
-- one block. Order types by their definition dependencies (a TABLE OF X
-- type must come AFTER X). DROP TYPE … FORCE cascades to dependents on
-- redeploys; the BEGIN/EXCEPTION absorbs the "doesn't exist" case on
-- first deploy.

-- Collection of h3 indices (hex string representation), returned by
-- H3_KRING, H3_HEXRING, H3_TOCHILDREN, H3_COMPACT, H3_UNCOMPACT,
-- H3_POLYFILL via PIPE ROW.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.H3_INDEX_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.H3_INDEX_ARRAY AS TABLE OF VARCHAR2(16);
/

-- (h3, distance) pair element of H3_KRING_DISTANCES output.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.H3_DISTANCE_PAIR FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.H3_DISTANCE_PAIR AS OBJECT (
    h3       VARCHAR2(16),
    distance NUMBER
);
/

-- Collection of (h3, distance) pairs. Must come AFTER H3_DISTANCE_PAIR
-- because the CREATE TYPE references it.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.H3_DISTANCE_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.H3_DISTANCE_ARRAY
    AS TABLE OF @@ORA_SCHEMA@@.H3_DISTANCE_PAIR;
/
