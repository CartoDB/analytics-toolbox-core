----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns a JSON array of all quadbin cell indexes that cover (intersect)
-- the given geometry at the specified resolution.
--
-- Algorithm  (bounding-box scan + intersection filter):
--   1. Compute the MBR (minimum bounding rectangle) of the input geometry.
--   2. Convert bbox corners to tile coordinates using Web Mercator math
--      (same formulas as QUADBIN_FROMLONGLAT).
--   3. Iterate every tile in the bounding-box range.
--   4. For each tile, build its boundary polygon via QUADBIN_BOUNDARY.
--   5. Keep the tile only if SDO_GEOM.RELATE reports ANYINTERACT with
--      the input geometry.
--   6. Return matching quadbin indices as a sorted JSON array (CLOB).
--
-- Uses BINARY_DOUBLE (IEEE 754) for Web Mercator calculations to match
-- the floating-point behaviour of other platforms.

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_POLYFILL
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN CLOB
AS
    MIN_RESOLUTION CONSTANT NUMBER := 0;
    MAX_RESOLUTION CONSTANT NUMBER := 26;
    LAT_CLAMP_MIN  CONSTANT BINARY_DOUBLE := -89.0d;
    LAT_CLAMP_MAX  CONSTANT BINARY_DOUBLE := 89.0d;

    v_geom       SDO_GEOMETRY;
    v_mbr        SDO_GEOMETRY;
    v_tile_geom  SDO_GEOMETRY;

    -- MBR corners (lon/lat)
    v_west       BINARY_DOUBLE;
    v_south      BINARY_DOUBLE;
    v_east       BINARY_DOUBLE;
    v_north      BINARY_DOUBLE;

    -- Web Mercator intermediates
    v_pi         BINARY_DOUBLE;
    v_num_tiles  BINARY_DOUBLE;
    v_sinlat     BINARY_DOUBLE;

    -- Tile coordinate ranges (inclusive)
    v_min_tx     NUMBER;
    v_max_tx     NUMBER;
    v_min_ty     NUMBER;
    v_max_ty     NUMBER;
    v_num_tiles_i NUMBER;

    -- Iteration variables
    v_qb         NUMBER;
    v_relate     VARCHAR2(20);

    -- Result building
    v_result     CLOB;
    v_first      BOOLEAN := TRUE;
    v_val        VARCHAR2(30);
BEGIN
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;

    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Invalid resolution: should be between '
                || MIN_RESOLUTION || ' and ' || MAX_RESOLUTION
        );
    END IF;

    -- Ensure input geometry has SRID 4326 so SDO_GEOM.RELATE works
    -- with the tile boundaries (which also use SRID 4326).
    IF geom.SDO_SRID IS NULL OR geom.SDO_SRID != 4326 THEN
        v_geom := geom;
        v_geom.SDO_SRID := 4326;
    ELSE
        v_geom := geom;
    END IF;

    -- Get MBR of the input geometry
    v_mbr := SDO_GEOM.SDO_MBR(v_geom);

    IF v_mbr IS NULL THEN
        -- Degenerate geometry (e.g., empty)
        DBMS_LOB.CREATETEMPORARY(v_result, TRUE);
        DBMS_LOB.WRITEAPPEND(v_result, 2, '[]');
        RETURN v_result;
    END IF;

    -- Extract MBR corners.
    -- SDO_MBR returns a rectangle as SDO_GEOMETRY with ordinates:
    --   (min_x, min_y, max_x, max_y) for optimized rectangle
    -- or (min_x, min_y, max_x, min_y, max_x, max_y, min_x, max_y, min_x, min_y)
    -- We handle both forms.
    IF v_mbr.SDO_POINT IS NOT NULL THEN
        -- Point geometry: MBR is the point itself
        v_west  := CAST(v_mbr.SDO_POINT.X AS BINARY_DOUBLE);
        v_south := CAST(v_mbr.SDO_POINT.Y AS BINARY_DOUBLE);
        v_east  := v_west;
        v_north := v_south;
    ELSIF v_mbr.SDO_ORDINATES IS NOT NULL AND v_mbr.SDO_ORDINATES.COUNT >= 4 THEN
        -- Rectangle or polygon MBR
        v_west  := CAST(v_mbr.SDO_ORDINATES(1) AS BINARY_DOUBLE);
        v_south := CAST(v_mbr.SDO_ORDINATES(2) AS BINARY_DOUBLE);
        IF v_mbr.SDO_ORDINATES.COUNT = 4 THEN
            -- Optimized rectangle: (min_x, min_y, max_x, max_y)
            v_east  := CAST(v_mbr.SDO_ORDINATES(3) AS BINARY_DOUBLE);
            v_north := CAST(v_mbr.SDO_ORDINATES(4) AS BINARY_DOUBLE);
        ELSE
            -- Polygon form: extract max from ordinates
            v_east  := CAST(v_mbr.SDO_ORDINATES(3) AS BINARY_DOUBLE);
            v_north := CAST(v_mbr.SDO_ORDINATES(6) AS BINARY_DOUBLE);
        END IF;
    ELSE
        -- Fallback: empty result
        DBMS_LOB.CREATETEMPORARY(v_result, TRUE);
        DBMS_LOB.WRITEAPPEND(v_result, 2, '[]');
        RETURN v_result;
    END IF;

    -- Web Mercator tile coordinate computation
    v_pi := ACOS(-1.0d);
    v_num_tiles := POWER(2.0d, CAST(resolution AS BINARY_DOUBLE));
    v_num_tiles_i := POWER(2, resolution);

    -- Convert SW corner (west, south) to tile coordinates
    -- This gives us the tile at the bottom-left of the bbox
    v_sinlat := SIN(
        GREATEST(LAT_CLAMP_MIN, LEAST(LAT_CLAMP_MAX, v_south)) * v_pi / 180.0d
    );
    v_max_ty := FLOOR(
        CAST(
            GREATEST(
                0.0d,
                LEAST(
                    v_num_tiles - 1.0d,
                    v_num_tiles * (
                        0.5d - 0.25d
                        * LN((1.0d + v_sinlat) / (1.0d - v_sinlat))
                        / v_pi
                    )
                )
            )
        AS NUMBER)
    );
    v_min_tx := FLOOR(v_num_tiles * ((v_west / 360.0d) + 0.5d));
    v_min_tx := BITAND(v_min_tx, v_num_tiles_i - 1);

    -- Convert NE corner (east, north) to tile coordinates
    -- This gives us the tile at the top-right of the bbox
    v_sinlat := SIN(
        GREATEST(LAT_CLAMP_MIN, LEAST(LAT_CLAMP_MAX, v_north)) * v_pi / 180.0d
    );
    v_min_ty := FLOOR(
        CAST(
            GREATEST(
                0.0d,
                LEAST(
                    v_num_tiles - 1.0d,
                    v_num_tiles * (
                        0.5d - 0.25d
                        * LN((1.0d + v_sinlat) / (1.0d - v_sinlat))
                        / v_pi
                    )
                )
            )
        AS NUMBER)
    );
    v_max_tx := FLOOR(v_num_tiles * ((v_east / 360.0d) + 0.5d));
    v_max_tx := BITAND(v_max_tx, v_num_tiles_i - 1);

    -- Build result CLOB
    DBMS_LOB.CREATETEMPORARY(v_result, TRUE);
    DBMS_LOB.WRITEAPPEND(v_result, 1, '[');

    -- Iterate all tiles in the bounding-box range
    FOR ty IN v_min_ty .. v_max_ty LOOP
        FOR tx IN v_min_tx .. v_max_tx LOOP
            -- Get quadbin index for this tile
            v_qb := @@ORA_SCHEMA@@.QUADBIN_FROMZXY(resolution, tx, ty);

            -- Get tile boundary polygon
            v_tile_geom := @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(v_qb);

            -- Check if tile intersects the input geometry
            v_relate := SDO_GEOM.RELATE(v_tile_geom, 'ANYINTERACT', v_geom, 0.0000001);

            IF v_relate = 'TRUE' THEN
                v_val := TO_CHAR(v_qb);
                IF v_first THEN
                    v_first := FALSE;
                ELSE
                    DBMS_LOB.WRITEAPPEND(v_result, 1, ',');
                END IF;
                DBMS_LOB.WRITEAPPEND(v_result, LENGTH(v_val), v_val);
            END IF;
        END LOOP;
    END LOOP;

    DBMS_LOB.WRITEAPPEND(v_result, 1, ']');

    RETURN v_result;
END;
/
