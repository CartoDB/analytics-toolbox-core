----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Pipelined coverage function with mode flag.
-- Approach: get the CENTER-mode cells from h3-js (fast, single MLE call),
-- then for 'intersects'/'contains' expand each center cell by kRing(1)
-- (the surrounding hex shell — small set) and filter the candidates with
-- SDO_GEOM.RELATE. Two-phase: cheap candidate set from JS, exact mode
-- predicate evaluated in PL/SQL.
CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_POLYFILL_MODE
(
    geom SDO_GEOMETRY, resolution NUMBER, polyfill_mode VARCHAR2
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
AS
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    TOLERANCE CONSTANT NUMBER := 0.0000001;

    v_mode      VARCHAR2(20);
    v_geom      SDO_GEOMETRY;
    v_geojson   CLOB;
    v_cells     CLOB;
    v_cell_raw  RAW(8);
    v_h3_geom   SDO_GEOMETRY;
    v_relates   VARCHAR2(20);
    v_geom_srid PLS_INTEGER;

    -- Set used for de-duplication across kring expansion.
    TYPE cell_set IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(16);
    candidates cell_set;
    accepted   cell_set;
    v_key      VARCHAR2(16);
BEGIN
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN;
    END IF;
    IF resolution < MIN_RESOLUTION OR resolution > MAX_RESOLUTION THEN
        RETURN;
    END IF;

    v_mode := LOWER(polyfill_mode);
    IF v_mode NOT IN ('center', 'intersects', 'contains') THEN
        RETURN;
    END IF;

    -- Ensure SRID 4326 for TO_GEOJSON
    IF geom.SDO_SRID IS NULL OR geom.SDO_SRID != 4326 THEN
        v_geom := geom;
        v_geom.SDO_SRID := 4326;
    ELSE
        v_geom := geom;
    END IF;
    v_geom_srid := v_geom.SDO_SRID;

    v_geojson := SDO_UTIL.TO_GEOJSON(v_geom);
    -- JS returns CENTER cells for Polygon/MultiPolygon inputs and []
    -- for any other geometry type.
    v_cells := @@ORA_SCHEMA@@.INTERNAL_H3_POLYFILL_JS(v_geojson, resolution);

    -- Center mode: pipe the h3-js polyfill output directly.
    IF v_mode = 'center' THEN
        FOR rec IN (
            SELECT jt.cell AS h3
            FROM JSON_TABLE(
                v_cells, '$[*]'
                COLUMNS (cell VARCHAR2(16) PATH '$')
            ) jt
        ) LOOP
            PIPE ROW(rec.h3);
        END LOOP;
        RETURN;
    END IF;

    -- Intersects / contains: build a candidate set (center cells
    -- + their kring-1 neighbours) and filter by SDO_GEOM.RELATE.
    FOR rec IN (
        SELECT jt.cell AS h3
        FROM JSON_TABLE(
            v_cells, '$[*]'
            COLUMNS (cell VARCHAR2(16) PATH '$')
        ) jt
    ) LOOP
        candidates(rec.h3) := 1;
        FOR ring IN (
            SELECT COLUMN_VALUE AS h3
            FROM TABLE(@@ORA_SCHEMA@@.H3_KRING(rec.h3, 1))
        ) LOOP
            candidates(ring.h3) := 1;
        END LOOP;
    END LOOP;

    v_key := candidates.FIRST;
    WHILE v_key IS NOT NULL LOOP
        BEGIN
            v_cell_raw := HEXTORAW(LPAD(v_key, RAW_BYTE_LENGTH, '0'));
            v_h3_geom := SDO_UTIL.H3_BOUNDARY(v_cell_raw);
            -- Re-build with the input geom's SRID (RELATE requires matching SRIDs)
            v_h3_geom := SDO_GEOMETRY(
                v_h3_geom.SDO_GTYPE,
                v_geom_srid,
                NULL,
                v_h3_geom.SDO_ELEM_INFO,
                v_h3_geom.SDO_ORDINATES
            );
            IF v_mode = 'contains' THEN
                -- INSIDE+COVEREDBY accepts cells whose boundary touches the
                -- input geometry's boundary; INSIDE alone is strict-interior
                -- and would drop most cells against an axis-aligned polygon.
                v_relates := SDO_GEOM.RELATE(
                    v_h3_geom, 'INSIDE+COVEREDBY', v_geom, TOLERANCE
                );
            ELSE
                v_relates := SDO_GEOM.RELATE(
                    v_h3_geom, 'ANYINTERACT', v_geom, TOLERANCE
                );
            END IF;
            -- SDO_GEOM.RELATE returns the matched mask name (e.g. 'INSIDE'
            -- or 'INSIDE+COVEREDBY') when some mask matches, or 'FALSE'
            -- otherwise. ANYINTERACT is the only mask that returns 'TRUE'.
            IF v_relates != 'FALSE' THEN
                accepted(v_key) := 1;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        v_key := candidates.NEXT(v_key);
    END LOOP;

    v_key := accepted.FIRST;
    WHILE v_key IS NOT NULL LOOP
        PIPE ROW(v_key);
        v_key := accepted.NEXT(v_key);
    END LOOP;

    RETURN;
EXCEPTION
    WHEN NO_DATA_NEEDED THEN
        RETURN;
    WHEN OTHERS THEN
        RETURN;
END H3_POLYFILL_MODE;
/
