----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Type used by this function. Inline declaration with idempotent DROP+CREATE.
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

-- Returns the center of a quadbin tile as an SDO_GEOMETRY point (SRID 4326).
--
-- Uses BINARY_DOUBLE (IEEE 754) for intermediate calculations to match
-- the floating-point behaviour of other platforms (Databricks DOUBLE, etc.).

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_CENTER
(quadbin NUMBER)
RETURN SDO_GEOMETRY
AS
    v_zxy       @@ORA_SCHEMA@@.QUADBIN_ZXY;
    v_z         BINARY_DOUBLE;
    v_x         BINARY_DOUBLE;
    v_y         BINARY_DOUBLE;
    v_num_tiles BINARY_DOUBLE;
    v_pi        BINARY_DOUBLE;
    v_center_lon BINARY_DOUBLE;
    v_center_lat BINARY_DOUBLE;
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

    -- Inverse Web Mercator for tile center (use x+0.5, y+0.5)
    v_center_lon := 180.0d * (2.0d * (v_x + 0.5d) / v_num_tiles - 1.0d);
    v_center_lat := 360.0d * (
        ATAN(EXP(-(2.0d * (v_y + 0.5d) / v_num_tiles - 1.0d) * v_pi))
        / v_pi - 0.25d
    );

    RETURN SDO_GEOMETRY(
        2001,
        4326,
        SDO_POINT_TYPE(v_center_lon, v_center_lat, NULL),
        NULL,
        NULL
    );
END;
/
