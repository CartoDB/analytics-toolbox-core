----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Type used by this function. Inline declaration with idempotent DROP+CREATE.
BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY FORCE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TYPE @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY AS TABLE OF NUMBER;
/

-- =====================================================================
-- QUADBIN_POLYFILL
--
-- Two-phase scan: estimate a coarse "init" resolution from geometry area,
-- bbox-scan at that resolution to get parent cells, expand each parent to
-- target resolution via QUADBIN_TOCHILDREN, then mode-filter the children.
--
-- Public entry: QUADBIN_POLYFILL(geom, resolution, polyfill_mode)
--   polyfill_mode = 'center' (default), 'intersects', 'contains'
-- Consume via:
--   SELECT COLUMN_VALUE FROM TABLE(QUADBIN_POLYFILL(geom, 17));
--   SELECT COLUMN_VALUE FROM TABLE(QUADBIN_POLYFILL(geom, 17, 'intersects'));
-- =====================================================================

-- Estimate the init resolution: the resolution at which a cell has
-- approximately the same area as the geometry, plus 3 levels finer.
-- Clamped to <= target resolution.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT_Z"
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN NUMBER
AS
    Q0_AREA   CONSTANT BINARY_DOUBLE := 61236.812721460745d;
    TOLERANCE CONSTANT BINARY_DOUBLE := 0.0000001d;
    v_area    NUMBER;
    v_init_z  NUMBER;
BEGIN
    BEGIN
        v_area := SDO_GEOM.SDO_AREA(geom, TOLERANCE);
    EXCEPTION WHEN OTHERS THEN
        v_area := 0;
    END;
    IF v_area IS NOT NULL AND v_area > 0 THEN
        -- -log4(area / Q0_area) gives the resolution at which a cell has
        -- the same area as the geometry; +3 picks a finer working level.
        v_init_z := TRUNC(-LOG(4, v_area / Q0_AREA)) + 3;
    ELSE
        v_init_z := resolution;
    END IF;
    RETURN LEAST(resolution, GREATEST(0, v_init_z));
END;
/

-- Bbox scan at the given resolution. Returns the set of tiles whose
-- boundary intersects the input geometry (no mode-specific filtering yet).
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT"
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    LAT_CLAMP_MIN    CONSTANT BINARY_DOUBLE := -89.0d;
    LAT_CLAMP_MAX    CONSTANT BINARY_DOUBLE := 89.0d;
    RELATE_TOLERANCE CONSTANT BINARY_DOUBLE := 0.0000001d;

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
    v_relate     VARCHAR2(20);
BEGIN
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;

    v_mbr := SDO_GEOM.SDO_MBR(geom);
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
            v_relate := SDO_GEOM.RELATE(
                geom, 'ANYINTERACT',
                @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(v_qb),
                RELATE_TOLERANCE
            );
            IF v_relate = 'TRUE' THEN
                PIPE ROW(v_qb);
            END IF;
        END LOOP;
    END LOOP;

    RETURN;
END;
/

-- 'intersects' mode: keep child if it intersects the input geometry.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_CHILDREN_INTERSECTS"
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    TOLERANCE CONSTANT BINARY_DOUBLE := 0.0000001d;
    v_init_z  NUMBER;
    v_relate  VARCHAR2(20);
BEGIN
    v_init_z := @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT_Z"(geom, resolution);

    IF resolution < v_init_z + 2 THEN
        -- Direct scan at target resolution (no expansion benefit).
        FOR rec IN (
            SELECT COLUMN_VALUE AS qb
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT"(geom, resolution))
        ) LOOP
            PIPE ROW(rec.qb);
        END LOOP;
    ELSE
        -- Coarse parent scan, then expand and refilter children.
        FOR p IN (
            SELECT COLUMN_VALUE AS parent
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT"(geom, v_init_z))
        ) LOOP
            FOR c IN (
                SELECT COLUMN_VALUE AS child
                FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_TOCHILDREN(p.parent, resolution))
            ) LOOP
                v_relate := SDO_GEOM.RELATE(
                    geom, 'ANYINTERACT',
                    @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(c.child),
                    TOLERANCE
                );
                IF v_relate = 'TRUE' THEN
                    PIPE ROW(c.child);
                END IF;
            END LOOP;
        END LOOP;
    END IF;
    RETURN;
END;
/

-- 'contains' mode: keep child only if input geometry fully contains the cell boundary.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_CHILDREN_CONTAINS"
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    TOLERANCE CONSTANT BINARY_DOUBLE := 0.0000001d;
    v_init_z  NUMBER;
    v_relate  VARCHAR2(20);
BEGIN
    v_init_z := @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT_Z"(geom, resolution);

    IF resolution < v_init_z + 2 THEN
        FOR rec IN (
            SELECT COLUMN_VALUE AS qb
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT"(geom, resolution))
        ) LOOP
            v_relate := SDO_GEOM.RELATE(
                geom, 'CONTAINS',
                @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(rec.qb),
                TOLERANCE
            );
            IF v_relate = 'CONTAINS' THEN
                PIPE ROW(rec.qb);
            END IF;
        END LOOP;
    ELSE
        FOR p IN (
            SELECT COLUMN_VALUE AS parent
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT"(geom, v_init_z))
        ) LOOP
            FOR c IN (
                SELECT COLUMN_VALUE AS child
                FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_TOCHILDREN(p.parent, resolution))
            ) LOOP
                v_relate := SDO_GEOM.RELATE(
                    geom, 'CONTAINS',
                    @@ORA_SCHEMA@@.QUADBIN_BOUNDARY(c.child),
                    TOLERANCE
                );
                IF v_relate = 'CONTAINS' THEN
                    PIPE ROW(c.child);
                END IF;
            END LOOP;
        END LOOP;
    END IF;
    RETURN;
END;
/

-- 'center' mode (default): keep child if input geometry intersects the cell center.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_CHILDREN_CENTER"
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    TOLERANCE CONSTANT BINARY_DOUBLE := 0.0000001d;
    v_init_z  NUMBER;
    v_relate  VARCHAR2(20);
BEGIN
    v_init_z := @@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT_Z"(geom, resolution);

    IF resolution < v_init_z + 2 THEN
        FOR rec IN (
            SELECT COLUMN_VALUE AS qb
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT"(geom, resolution))
        ) LOOP
            v_relate := SDO_GEOM.RELATE(
                geom, 'ANYINTERACT',
                @@ORA_SCHEMA@@.QUADBIN_CENTER(rec.qb),
                TOLERANCE
            );
            IF v_relate = 'TRUE' THEN
                PIPE ROW(rec.qb);
            END IF;
        END LOOP;
    ELSE
        FOR p IN (
            SELECT COLUMN_VALUE AS parent
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_INIT"(geom, v_init_z))
        ) LOOP
            FOR c IN (
                SELECT COLUMN_VALUE AS child
                FROM TABLE(@@ORA_SCHEMA@@.QUADBIN_TOCHILDREN(p.parent, resolution))
            ) LOOP
                v_relate := SDO_GEOM.RELATE(
                    geom, 'ANYINTERACT',
                    @@ORA_SCHEMA@@.QUADBIN_CENTER(c.child),
                    TOLERANCE
                );
                IF v_relate = 'TRUE' THEN
                    PIPE ROW(c.child);
                END IF;
            END LOOP;
        END LOOP;
    END IF;
    RETURN;
END;
/

-- Public function with explicit mode. NULL-on-invalid: empty pipeline for
-- invalid resolution or NULL inputs.
-- Two separate functions (POLYFILL / POLYFILL_MODE) instead of a single
-- function with a DEFAULT parameter, because Oracle doesn't honor DEFAULT
-- subprogram parameters when called from SQL via positional arguments.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_POLYFILL_MODE
(geom SDO_GEOMETRY, resolution NUMBER, polyfill_mode VARCHAR2)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    v_geom SDO_GEOMETRY;
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

    IF polyfill_mode = 'intersects' THEN
        FOR r IN (
            SELECT COLUMN_VALUE AS qb
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_CHILDREN_INTERSECTS"(v_geom, resolution))
        ) LOOP
            PIPE ROW(r.qb);
        END LOOP;
    ELSIF polyfill_mode = 'contains' THEN
        FOR r IN (
            SELECT COLUMN_VALUE AS qb
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_CHILDREN_CONTAINS"(v_geom, resolution))
        ) LOOP
            PIPE ROW(r.qb);
        END LOOP;
    ELSIF polyfill_mode = 'center' THEN
        FOR r IN (
            SELECT COLUMN_VALUE AS qb
            FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_CHILDREN_CENTER"(v_geom, resolution))
        ) LOOP
            PIPE ROW(r.qb);
        END LOOP;
    END IF;
    -- Unknown mode: empty pipeline.
    RETURN;
END;
/

-- Public 2-arg form: defaults to 'center' mode.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.QUADBIN_POLYFILL
(geom SDO_GEOMETRY, resolution NUMBER)
RETURN @@ORA_SCHEMA@@.QUADBIN_INDEX_ARRAY PIPELINED
AS
    v_geom SDO_GEOMETRY;
BEGIN
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;

    IF resolution < 0 OR resolution > 26 THEN
        RETURN;
    END IF;

    IF geom.SDO_SRID IS NULL OR geom.SDO_SRID != 4326 THEN
        v_geom := geom;
        v_geom.SDO_SRID := 4326;
    ELSE
        v_geom := geom;
    END IF;

    FOR r IN (
        SELECT COLUMN_VALUE AS qb
        FROM TABLE(@@ORA_SCHEMA@@."__QUADBIN_POLYFILL_CHILDREN_CENTER"(v_geom, resolution))
    ) LOOP
        PIPE ROW(r.qb);
    END LOOP;
    RETURN;
END;
/
