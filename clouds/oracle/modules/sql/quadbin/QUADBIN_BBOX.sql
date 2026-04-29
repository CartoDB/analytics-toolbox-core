----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the bounding box for a quadbin tile as a QUADBIN_BBOX_OBJ
-- (west, south, east, north in WGS84 degrees), using inverse Web Mercator.
-- BINARY_DOUBLE (IEEE 754) is used for intermediate calculations.

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_BBOX
(quadbin NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_BBOX_OBJ
AS
    v_zxy      @@ORA_SCHEMA@@.QUADBIN_ZXY;
    v_z        BINARY_DOUBLE;
    v_x        BINARY_DOUBLE;
    v_y        BINARY_DOUBLE;
    v_num_tiles BINARY_DOUBLE;
    v_pi       BINARY_DOUBLE;
    v_west     BINARY_DOUBLE;
    v_south    BINARY_DOUBLE;
    v_east     BINARY_DOUBLE;
    v_north    BINARY_DOUBLE;
BEGIN
    IF quadbin IS NULL THEN
        RETURN NULL;
    END IF;

    v_zxy := @@ORA_SCHEMA@@.QUADBIN_TOZXY(quadbin);

    v_z := CAST(v_zxy.z AS BINARY_DOUBLE);
    v_x := CAST(v_zxy.x AS BINARY_DOUBLE);
    v_y := CAST(v_zxy.y AS BINARY_DOUBLE);

    v_num_tiles := POWER(2.0d, v_z);
    v_pi := ACOS(-1.0d);

    -- Inverse Web Mercator for bounds
    v_west  := 180.0d * (2.0d * v_x / v_num_tiles - 1.0d);
    v_east  := 180.0d * (2.0d * (v_x + 1.0d) / v_num_tiles - 1.0d);
    v_south := 360.0d * (
        ATAN(EXP(-(2.0d * (v_y + 1.0d) / v_num_tiles - 1.0d) * v_pi))
        / v_pi - 0.25d
    );
    v_north := 360.0d * (
        ATAN(EXP(-(2.0d * v_y / v_num_tiles - 1.0d) * v_pi))
        / v_pi - 0.25d
    );

    RETURN @@ORA_SCHEMA@@.QUADBIN_BBOX_OBJ(v_west, v_south, v_east, v_north);
END;
/
