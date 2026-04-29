----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Type used by this function. Inline declaration with idempotent DROP+CREATE.
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

-- Returns the boundary of a quadbin tile as an SDO_GEOMETRY polygon (SRID 4326).
-- Calls QUADBIN_BBOX to get [west, south, east, north], then constructs
-- a polygon from the four corners.

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_BOUNDARY
(quadbin NUMBER)
RETURN SDO_GEOMETRY
AS
    v_bbox  @@ORA_SCHEMA@@.QUADBIN_BBOX_OBJ;
    v_west  NUMBER;
    v_south NUMBER;
    v_east  NUMBER;
    v_north NUMBER;
BEGIN
    IF quadbin IS NULL THEN
        RETURN NULL;
    END IF;

    v_bbox := @@ORA_SCHEMA@@.QUADBIN_BBOX(quadbin);

    v_west  := v_bbox.west;
    v_south := v_bbox.south;
    v_east  := v_bbox.east;
    v_north := v_bbox.north;

    -- Construct polygon. Vertex order: NW → SW → SE → NE → NW close.
    RETURN SDO_GEOMETRY(
        2003,
        4326,
        NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 1),
        SDO_ORDINATE_ARRAY(
            v_west, v_north,
            v_west, v_south,
            v_east, v_south,
            v_east, v_north,
            v_west, v_north
        )
    );
END;
/
