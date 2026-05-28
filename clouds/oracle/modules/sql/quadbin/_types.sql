----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Shared types for the quadbin module. Single source of truth — referenced
-- by every QUADBIN_* function that uses a custom type. Deploy ordering is
-- handled automatically by build_modules.js dependency detection.
--
-- Each type is paired (drop + create) so adding a new type means inserting
-- one block. Order types by their definition dependencies (a TABLE OF X
-- type must come AFTER X). DROP TYPE … FORCE cascades to dependents on
-- redeploys; the BEGIN/EXCEPTION absorbs the "doesn't exist" case on
-- first deploy.

-- Tile coordinates returned by QUADBIN_TOZXY.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_ZXY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_ZXY AS OBJECT (
    z NUMBER,
    x NUMBER,
    y NUMBER
);
/

-- Geographic bounding box (WGS84 degrees) returned by QUADBIN_BBOX.
-- Suffix _OBJ avoids collision with the function name QUADBIN_BBOX.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_BBOX_OBJ FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_BBOX_OBJ AS OBJECT (
    west  BINARY_DOUBLE,
    south BINARY_DOUBLE,
    east  BINARY_DOUBLE,
    north BINARY_DOUBLE
);
/

-- Collection of quadbin indices, returned by QUADBIN_KRING,
-- QUADBIN_TOCHILDREN, QUADBIN_POLYFILL via PIPE ROW.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY AS TABLE OF NUMBER;
/

-- (index, distance) pair element of QUADBIN_KRING_DISTANCES output.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR AS OBJECT (
    quadbin_index NUMBER,
    distance      NUMBER
);
/

-- Collection of (index, distance) pairs. Must come AFTER QUADBIN_DISTANCE_PAIR
-- because the CREATE TYPE references it.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_DISTANCE_ARRAY
    AS TABLE OF @@ORA_SCHEMA@@.QUADBIN_DISTANCE_PAIR;
/
