----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Extracts longitude/latitude from an SDO_GEOMETRY point and delegates
-- to QUADBIN_FROMLONGLAT for the actual quadbin computation.
--
-- Oracle SDO_GEOMETRY point access:
--   point.SDO_POINT.X = longitude
--   point.SDO_POINT.Y = latitude

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_FROMGEOGPOINT
(point SDO_GEOMETRY, resolution NUMBER)
RETURN NUMBER
AS
BEGIN
    IF point IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(
        point.SDO_POINT.X,
        point.SDO_POINT.Y,
        resolution
    );
END;
/
