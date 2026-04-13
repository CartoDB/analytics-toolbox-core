----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Extracts longitude/latitude from an SDO_GEOMETRY point and delegates
-- to QUADBIN_FROMLONGLAT for the actual quadbin computation.
--
-- Handles both SDO_POINT and SDO_ORDINATES representations, since
-- Oracle SDO_GEOMETRY can store point coordinates in either location
-- depending on how the geometry was constructed.

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_FROMGEOGPOINT
(point SDO_GEOMETRY, resolution NUMBER)
RETURN NUMBER
AS
    v_lon NUMBER;
    v_lat NUMBER;
BEGIN
    IF point IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;

    v_lon := point.SDO_POINT.X;
    v_lat := point.SDO_POINT.Y;

    -- Fallback to SDO_ORDINATES if SDO_POINT is not populated
    IF v_lon IS NULL
       AND point.SDO_ORDINATES IS NOT NULL
       AND point.SDO_ORDINATES.COUNT >= 2
    THEN
        v_lon := point.SDO_ORDINATES(1);
        v_lat := point.SDO_ORDINATES(2);
    END IF;

    RETURN @@ORA_SCHEMA@@.QUADBIN_FROMLONGLAT(v_lon, v_lat, resolution);
END;
/
