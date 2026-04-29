----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- =====================================================================
-- QUADBIN_POLYFILL
--
-- Single-phase bbox scan at the target resolution with inline mode
-- predicate dispatch. Mode controls which cells are kept:
--   'center'    — geometry must intersect the cell center (default form)
--   'intersects' — cell boundary must intersect the geometry
--   'contains'  — geometry must fully contain the cell boundary
--
-- Two public entry points:
--   QUADBIN_POLYFILL(geom, resolution)            — defaults to 'center'
--   QUADBIN_POLYFILL_MODE(geom, resolution, mode) — explicit mode
--
-- Consume via: SELECT COLUMN_VALUE FROM TABLE(QUADBIN_POLYFILL(...));
--
-- NULL-on-invalid: returns an empty pipeline for NULL inputs or
-- out-of-range resolution (per .claude/rules/oracle.md).
-- =====================================================================

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_POLYFILL_MODE
(geom SDO_GEOMETRY, resolution NUMBER, polyfill_mode VARCHAR2)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    LAT_CLAMP_MIN    CONSTANT BINARY_DOUBLE := -89.0d;
    LAT_CLAMP_MAX    CONSTANT BINARY_DOUBLE := 89.0d;
    RELATE_TOLERANCE CONSTANT BINARY_DOUBLE := 0.0000001d;

    v_geom       SDO_GEOMETRY;
    v_mbr        SDO_GEOMETRY;
    v_west       BINARY_DOUBLE;
    v_south      BINARY_DOUBLE;
    v_east       BINARY_DOUBLE;
    v_north      BINARY_DOUBLE;

    v_pi         BINARY_DOUBLE;
    v_z2         BINARY_DOUBLE;
    v_z2_int     NUMBER;
    v_sinlat_min BINARY_DOUBLE;
    v_sinlat_max BINARY_DOUBLE;

    v_xmin       NUMBER;
    v_xmax       NUMBER;
    v_ymin       NUMBER;
    v_ymax       NUMBER;
    v_tx_count   NUMBER;
    v_tx         NUMBER;
    v_qb         NUMBER;

    v_tile_geom  SDO_GEOMETRY;
    v_test_geom  SDO_GEOMETRY;
    v_relation   VARCHAR2(20);
    v_keep       BOOLEAN;
BEGIN
    IF geom IS NULL OR resolution IS NULL OR polyfill_mode IS NULL THEN
        RETURN;
    END IF;
    IF resolution < 0 OR resolution > 26 THEN
        RETURN;
    END IF;

    -- Ensure SRID 4326 so SDO_GEOM.RELATE works against tile boundaries.
    IF geom.SDO_SRID IS NULL OR geom.SDO_SRID != 4326 THEN
        v_geom := geom;
        v_geom.SDO_SRID := 4326;
    ELSE
        v_geom := geom;
    END IF;

    v_mbr := SDO_GEOM.SDO_MBR(v_geom);
    IF v_mbr IS NULL THEN
        RETURN;
    END IF;

    -- Extract MBR corners. Point inputs come back with SDO_POINT set;
    -- regular geometries use SDO_ORDINATES (4-element optimized rectangle).
    IF v_mbr.SDO_POINT IS NOT NULL THEN
        v_west  := CAST(v_mbr.SDO_POINT.X AS BINARY_DOUBLE);
        v_south := CAST(v_mbr.SDO_POINT.Y AS BINARY_DOUBLE);
        v_east  := v_west;
        v_north := v_south;
    ELSIF v_mbr.SDO_ORDINATES IS NOT NULL AND v_mbr.SDO_ORDINATES.COUNT >= 4 THEN
        v_west  := CAST(v_mbr.SDO_ORDINATES(1) AS BINARY_DOUBLE);
        v_south := CAST(v_mbr.SDO_ORDINATES(2) AS BINARY_DOUBLE);
        v_east  := CAST(v_mbr.SDO_ORDINATES(3) AS BINARY_DOUBLE);
        v_north := CAST(v_mbr.SDO_ORDINATES(4) AS BINARY_DOUBLE);
    ELSE
        RETURN;
    END IF;

    v_pi     := ACOS(-1.0d);
    v_z2     := POWER(2.0d, CAST(resolution AS BINARY_DOUBLE));
    v_z2_int := POWER(2, resolution);

    v_sinlat_min := SIN(GREATEST(LAT_CLAMP_MIN, LEAST(LAT_CLAMP_MAX, v_south)) * v_pi / 180.0d);
    v_sinlat_max := SIN(GREATEST(LAT_CLAMP_MIN, LEAST(LAT_CLAMP_MAX, v_north)) * v_pi / 180.0d);

    v_xmin := FLOOR(v_z2 * ((v_west / 360.0d) + 0.5d));
    v_xmax := FLOOR(v_z2 * ((v_east / 360.0d) + 0.5d));
    v_ymin := FLOOR(GREATEST(0.0d, LEAST(v_z2 - 1.0d,
        v_z2 * (0.5d - 0.25d * LN((1.0d + v_sinlat_max) / (1.0d - v_sinlat_max)) / v_pi)
    )));
    v_ymax := FLOOR(GREATEST(0.0d, LEAST(v_z2 - 1.0d,
        v_z2 * (0.5d - 0.25d * LN((1.0d + v_sinlat_min) / (1.0d - v_sinlat_min)) / v_pi)
    )));

    -- Antimeridian-safe iteration: count is unwrapped, then BITAND wraps
    -- each x into [0, 2^z) on the torus.
    v_tx_count := v_xmax - v_xmin + 1;

    FOR ty IN v_ymin .. v_ymax LOOP
        FOR i IN 0 .. v_tx_count - 1 LOOP
            v_tx := BITAND(v_xmin + i, v_z2_int - 1);
            v_qb := @@ORA_SCHEMA@@.QUADBIN_FROMZXY(resolution, v_tx, ty);

            -- Apply the mode predicate inline. 'center' tests against the
            -- tile center point; 'intersects' / 'contains' against the
            -- full tile boundary polygon.
            IF polyfill_mode = 'center' THEN
                v_test_geom := @@ORA_SCHEMA@@.QUADBIN_CENTER(v_qb);
                v_relation := SDO_GEOM.RELATE(
                    v_geom, 'ANYINTERACT', v_test_geom, RELATE_TOLERANCE
                );
                v_keep := (v_relation = 'TRUE');
            ELSIF polyfill_mode = 'intersects' THEN
                v_tile_geom := @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(v_qb);
                v_relation := SDO_GEOM.RELATE(
                    v_geom, 'ANYINTERACT', v_tile_geom, RELATE_TOLERANCE
                );
                v_keep := (v_relation = 'TRUE');
            ELSIF polyfill_mode = 'contains' THEN
                v_tile_geom := @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(v_qb);
                v_relation := SDO_GEOM.RELATE(
                    v_geom, 'CONTAINS', v_tile_geom, RELATE_TOLERANCE
                );
                v_keep := (v_relation = 'CONTAINS');
            ELSE
                v_keep := FALSE;
            END IF;

            IF v_keep THEN
                PIPE ROW(v_qb);
            END IF;
        END LOOP;
    END LOOP;

    RETURN;
END;
/

-- 2-arg form: defaults to 'center' mode.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_POLYFILL
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
BEGIN
    FOR r IN (
        SELECT COLUMN_VALUE AS qb
        FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_POLYFILL_MODE(geom, resolution, 'center'))
    ) LOOP
        PIPE ROW(r.qb);
    END LOOP;
    RETURN;
END;
/
