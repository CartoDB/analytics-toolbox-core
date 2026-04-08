----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the boundary of a quadbin tile as an SDO_GEOMETRY polygon (SRID 4326).
-- Calls QUADBIN_BBOX to get [west, south, east, north], then constructs
-- a polygon from the four corners.

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_BOUNDARY
(quadbin NUMBER)
RETURN SDO_GEOMETRY
AS
    v_bbox  VARCHAR2(400);
    v_west  NUMBER;
    v_south NUMBER;
    v_east  NUMBER;
    v_north NUMBER;
BEGIN
    IF quadbin IS NULL THEN
        RETURN NULL;
    END IF;

    -- Get bounding box as JSON array: [west, south, east, north]
    v_bbox := @@ORA_SCHEMA@@.QUADBIN_BBOX(quadbin);

    v_west  := TO_NUMBER(JSON_VALUE(v_bbox, '$[0]'));
    v_south := TO_NUMBER(JSON_VALUE(v_bbox, '$[1]'));
    v_east  := TO_NUMBER(JSON_VALUE(v_bbox, '$[2]'));
    v_north := TO_NUMBER(JSON_VALUE(v_bbox, '$[3]'));

    -- Construct polygon (counterclockwise exterior ring)
    RETURN SDO_GEOMETRY(
        2003,
        4326,
        NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 1),
        SDO_ORDINATE_ARRAY(
            v_west, v_south,
            v_east, v_south,
            v_east, v_north,
            v_west, v_north,
            v_west, v_south
        )
    );
END;
/
