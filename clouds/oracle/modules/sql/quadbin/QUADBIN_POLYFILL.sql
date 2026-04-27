----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all quadbin cell indexes that cover (intersect) the given
-- geometry at the specified resolution, as a pipelined QUADBIN_INDEX_ARRAY.
--
-- Consume via:
--   SELECT COLUMN_VALUE FROM TABLE(QUADBIN_POLYFILL(geom, resolution));
--
-- Algorithm  (bounding-box scan + intersection filter):
--   1. Compute the MBR (minimum bounding rectangle) of the input geometry.
--   2. Convert bbox corners to tile coordinates using Web Mercator math
--      (same formulas as QUADBIN_FROMLONGLAT).
--   3. Iterate every tile in the bounding-box range, wrapping x for
--      antimeridian-crossing bboxes.
--   4. For each tile, build its boundary polygon via QUADBIN_BOUNDARY.
--   5. Pipe the tile only if SDO_GEOM.RELATE reports ANYINTERACT.
--
-- BINARY_DOUBLE (IEEE 754) is used for Web Mercator calculations to match
-- the floating-point behaviour of other platforms.
--
-- NULL-on-invalid: out-of-range resolution returns an empty pipeline
-- (per .claude/rules/oracle.md). Input geometry without an explicit SRID
-- is assumed WGS84 (EPSG:4326).

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_POLYFILL
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    MIN_RESOLUTION CONSTANT NUMBER := 0;
    MAX_RESOLUTION CONSTANT NUMBER := 26;
    LAT_CLAMP_MIN  CONSTANT BINARY_DOUBLE := -89.0d;
    LAT_CLAMP_MAX  CONSTANT BINARY_DOUBLE := 89.0d;
    RELATE_TOLERANCE CONSTANT BINARY_DOUBLE := 0.0000001d;

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
    v_tx_count   NUMBER;

    -- Iteration variables
    v_tx         NUMBER;
    v_qb         NUMBER;
    v_relate     VARCHAR2(20);
BEGIN
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;

    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RETURN;
    END IF;

    -- Ensure input geometry has SRID 4326 so SDO_GEOM.RELATE works
    -- with the tile boundaries (which also use SRID 4326).
    IF geom.SDO_SRID IS NULL OR geom.SDO_SRID != 4326 THEN
        v_geom := geom;
        v_geom.SDO_SRID := 4326;
    ELSE
        v_geom := geom;
    END IF;

    v_mbr := SDO_GEOM.SDO_MBR(v_geom);

    IF v_mbr IS NULL THEN
        -- Degenerate geometry (e.g., empty)
        RETURN;
    END IF;

    -- Extract MBR corners. SDO_MBR returns either:
    --   (a) a point geometry (SDO_POINT) for a single-point input, or
    --   (b) a rectangle/polygon with SDO_ORDINATES.
    IF v_mbr.SDO_POINT IS NOT NULL THEN
        v_west  := CAST(v_mbr.SDO_POINT.X AS BINARY_DOUBLE);
        v_south := CAST(v_mbr.SDO_POINT.Y AS BINARY_DOUBLE);
        v_east  := v_west;
        v_north := v_south;
    ELSIF v_mbr.SDO_ORDINATES IS NOT NULL AND v_mbr.SDO_ORDINATES.COUNT >= 4 THEN
        v_west  := CAST(v_mbr.SDO_ORDINATES(1) AS BINARY_DOUBLE);
        v_south := CAST(v_mbr.SDO_ORDINATES(2) AS BINARY_DOUBLE);
        IF v_mbr.SDO_ORDINATES.COUNT = 4 THEN
            -- Optimized rectangle: (min_x, min_y, max_x, max_y)
            v_east  := CAST(v_mbr.SDO_ORDINATES(3) AS BINARY_DOUBLE);
            v_north := CAST(v_mbr.SDO_ORDINATES(4) AS BINARY_DOUBLE);
        ELSE
            -- Polygon form: (min_x, min_y, max_x, min_y, max_x, max_y, ...)
            v_east  := CAST(v_mbr.SDO_ORDINATES(3) AS BINARY_DOUBLE);
            v_north := CAST(v_mbr.SDO_ORDINATES(6) AS BINARY_DOUBLE);
        END IF;
    ELSE
        RETURN;
    END IF;

    -- Web Mercator tile coordinate computation
    v_pi := ACOS(-1.0d);
    v_num_tiles := POWER(2.0d, CAST(resolution AS BINARY_DOUBLE));
    v_num_tiles_i := POWER(2, resolution);

    -- Convert SW corner (west, south) to tile coordinates
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
    -- Keep raw (unwrapped) tx so that antimeridian crossings
    -- (where east < west after wrapping) produce a correct count.
    v_min_tx := FLOOR(v_num_tiles * ((v_west / 360.0d) + 0.5d));

    -- Convert NE corner (east, north) to tile coordinates
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

    -- Tile count from raw (unwrapped) coordinates handles antimeridian
    -- crossings correctly: when the bbox spans the dateline, v_max_tx
    -- is still >= v_min_tx in raw space.
    v_tx_count := v_max_tx - v_min_tx + 1;

    FOR ty IN v_min_ty .. v_max_ty LOOP
        FOR i IN 0 .. v_tx_count - 1 LOOP
            v_tx := BITAND(v_min_tx + i, v_num_tiles_i - 1);

            v_qb := @@ORA_SCHEMA@@.QUADBIN_FROMZXY(resolution, v_tx, ty);
            v_tile_geom := @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(v_qb);
            v_relate := SDO_GEOM.RELATE(
                v_tile_geom, 'ANYINTERACT', v_geom, RELATE_TOLERANCE
            );

            IF v_relate = 'TRUE' THEN
                PIPE ROW(v_qb);
            END IF;
        END LOOP;
    END LOOP;

    RETURN;
END;
/
