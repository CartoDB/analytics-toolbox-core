----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@."__H3_POLYFILL_MODE"
(
    geom SDO_GEOMETRY, resolution NUMBER, polyfill_mode VARCHAR2
)
RETURN VARCHAR2
IS
    -- Constants
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    SRID_WGS84 CONSTANT PLS_INTEGER := 4326;
    POINT_GTYPE CONSTANT PLS_INTEGER := 2001;
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;
    TOLERANCE CONSTANT NUMBER := 0.0000001;

    -- Geometry type constants
    GTYPE_POLYGON CONSTANT PLS_INTEGER := 3;
    GTYPE_MULTIPOLYGON CONSTANT PLS_INTEGER := 7;
    GTYPE_COLLECTION CONSTANT PLS_INTEGER := 4;

    -- H3 average edge lengths in meters by resolution
    TYPE edge_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    edge_lengths edge_array;

    -- Working variables
    res PLS_INTEGER;
    gtype PLS_INTEGER;
    v_mode VARCHAR2(20);
    mbr SDO_GEOMETRY;
    mbr_ords SDO_ORDINATE_ARRAY;
    west NUMBER;
    south NUMBER;
    east NUMBER;
    north NUMBER;
    center_lat NUMBER;
    edge_m NUMBER;
    step_lat NUMBER;
    step_lon NUMBER;
    cos_lat NUMBER;
    grid_lat NUMBER;
    grid_lon NUMBER;
    sample_point SDO_GEOMETRY;
    cell_raw RAW(8);
    cell_hex VARCHAR2(16);
    relates_result VARCHAR2(20);
    h3_geom SDO_GEOMETRY;
    check_geom SDO_GEOMETRY;
    geom_srid PLS_INTEGER;
    h3_boundary SDO_GEOMETRY;
    h3_ords SDO_ORDINATE_ARRAY;

    OVERSAMPLE_FACTOR CONSTANT NUMBER := 0.35;
    METERS_PER_DEGREE CONSTANT NUMBER := 111320;

    -- Candidate cells
    TYPE cell_map IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(16);
    candidates cell_map;

    -- Result map (sorted by key order)
    TYPE sorted_map IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(16);
    result_map sorted_map;
    v_key VARCHAR2(16);

    -- JSON building
    json_result VARCHAR2(32767);
    first_entry BOOLEAN;
BEGIN
    -- Null guards
    IF geom IS NULL OR resolution IS NULL THEN
        RETURN NULL;
    END IF;

    res := TRUNC(resolution);
    IF res < MIN_RESOLUTION OR res > MAX_RESOLUTION THEN
        RETURN NULL;
    END IF;

    v_mode := LOWER(polyfill_mode);
    IF v_mode NOT IN ('center', 'intersects') THEN
        RETURN NULL;
    END IF;

    -- Only polygon types are supported
    gtype := geom.GET_GTYPE();
    IF gtype NOT IN (GTYPE_POLYGON, GTYPE_MULTIPOLYGON, GTYPE_COLLECTION) THEN
        RETURN NULL;
    END IF;

    -- Track input SRID to match on H3 geometry outputs
    geom_srid := geom.SDO_SRID;

    -- Initialize edge lengths
    edge_lengths(0) := 1281256.011;
    edge_lengths(1) := 483056.8391;
    edge_lengths(2) := 182512.9565;
    edge_lengths(3) := 68979.22179;
    edge_lengths(4) := 26071.75968;
    edge_lengths(5) := 9854.090990;
    edge_lengths(6) := 3724.532667;
    edge_lengths(7) := 1406.475763;
    edge_lengths(8) := 531.414010;
    edge_lengths(9) := 200.786148;
    edge_lengths(10) := 75.863783;
    edge_lengths(11) := 28.663897;
    edge_lengths(12) := 10.830188;
    edge_lengths(13) := 4.092010;
    edge_lengths(14) := 1.546100;
    edge_lengths(15) := 0.584169;

    edge_m := edge_lengths(res);

    -- Compute bounding box
    mbr := SDO_GEOM.SDO_MBR(geom);
    IF mbr IS NULL THEN
        RETURN NULL;
    END IF;

    mbr_ords := mbr.SDO_ORDINATES;
    IF mbr_ords IS NULL OR mbr_ords.COUNT < 4 THEN
        RETURN NULL;
    END IF;

    west := mbr_ords(1);
    south := mbr_ords(2);
    east := mbr_ords(3);
    north := mbr_ords(4);

    -- Compute sampling step in degrees
    center_lat := (south + north) / 2;
    cos_lat := COS(center_lat * 3.14159265358979323846 / 180);
    IF cos_lat < 0.01 THEN
        cos_lat := 0.01;
    END IF;

    step_lat := (edge_m * OVERSAMPLE_FACTOR) / METERS_PER_DEGREE;
    step_lon := step_lat / cos_lat;

    IF step_lat < 0.0000001 THEN
        step_lat := 0.0000001;
    END IF;
    IF step_lon < 0.0000001 THEN
        step_lon := 0.0000001;
    END IF;

    -- Phase 1: Generate sample points and collect candidate cells
    grid_lat := south - step_lat;
    WHILE grid_lat <= north + step_lat LOOP
        grid_lon := west - step_lon;
        WHILE grid_lon <= east + step_lon LOOP
            sample_point := SDO_GEOMETRY(
                POINT_GTYPE, SRID_WGS84,
                SDO_POINT_TYPE(grid_lon, grid_lat, NULL),
                NULL, NULL
            );
            BEGIN
                cell_raw := SDO_UTIL.H3_KEY(sample_point, res);
                cell_hex := LOWER(LTRIM(RAWTOHEX(cell_raw), '0'));
                IF cell_hex IS NOT NULL AND LENGTH(cell_hex) > 0 THEN
                    IF NOT candidates.EXISTS(cell_hex) THEN
                        candidates(cell_hex) := 1;
                    END IF;
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
            grid_lon := grid_lon + step_lon;
        END LOOP;
        grid_lat := grid_lat + step_lat;
    END LOOP;

    -- Phase 2: Filter candidates based on mode
    v_key := candidates.FIRST;
    WHILE v_key IS NOT NULL LOOP
        BEGIN
            cell_raw := HEXTORAW(LPAD(v_key, RAW_BYTE_LENGTH, '0'));
            IF v_mode = 'center' THEN
                -- Center mode: cell center must be inside geometry
                -- Re-create center with matching SRID
                h3_geom := SDO_UTIL.H3_CENTER(cell_raw);
                check_geom := SDO_GEOMETRY(
                    POINT_GTYPE, geom_srid,
                    SDO_POINT_TYPE(
                        h3_geom.SDO_POINT.X,
                        h3_geom.SDO_POINT.Y,
                        NULL
                    ),
                    NULL, NULL
                );
            ELSE
                -- Intersects mode: cell boundary must intersect geometry
                -- Re-create boundary with matching SRID
                h3_boundary := SDO_UTIL.H3_BOUNDARY(cell_raw);
                h3_ords := h3_boundary.SDO_ORDINATES;
                check_geom := SDO_GEOMETRY(
                    h3_boundary.SDO_GTYPE,
                    geom_srid,
                    NULL,
                    h3_boundary.SDO_ELEM_INFO,
                    h3_ords
                );
            END IF;
            relates_result := SDO_GEOM.RELATE(
                check_geom,
                'ANYINTERACT',
                geom,
                TOLERANCE
            );
            IF relates_result = 'TRUE' THEN
                result_map(v_key) := 1;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        v_key := candidates.NEXT(v_key);
    END LOOP;

    -- Phase 3: Build sorted JSON array
    IF result_map.COUNT = 0 THEN
        RETURN NULL;
    END IF;

    json_result := '[';
    first_entry := TRUE;
    v_key := result_map.FIRST;
    WHILE v_key IS NOT NULL LOOP
        IF first_entry THEN
            first_entry := FALSE;
        ELSE
            json_result := json_result || ',';
        END IF;
        json_result := json_result || '"' || v_key || '"';
        v_key := result_map.NEXT(v_key);
    END LOOP;
    json_result := json_result || ']';

    RETURN json_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END "__H3_POLYFILL_MODE";
/

CREATE OR REPLACE PROCEDURE @@ORA_SCHEMA@@.H3_POLYFILL_TABLE
(
    input_query VARCHAR2,
    resolution NUMBER,
    polyfill_mode VARCHAR2,
    output_table VARCHAR2
)
IS
    ERR_INVALID_MODE CONSTANT PLS_INTEGER := -20001;
    ERR_INVALID_RES CONSTANT PLS_INTEGER := -20002;
    MIN_RESOLUTION CONSTANT PLS_INTEGER := 0;
    MAX_RESOLUTION CONSTANT PLS_INTEGER := 15;

    v_mode VARCHAR2(20);
    v_res PLS_INTEGER;
    v_sql CLOB;
    v_schema VARCHAR2(128);
BEGIN
    -- Validate mode
    v_mode := LOWER(polyfill_mode);
    IF v_mode NOT IN ('center', 'intersects') THEN
        RAISE_APPLICATION_ERROR(
            ERR_INVALID_MODE,
            'Invalid mode: ' || polyfill_mode
                || '. Must be ''center'' or ''intersects''.'
        );
    END IF;

    -- Validate resolution
    v_res := TRUNC(resolution);
    IF v_res < MIN_RESOLUTION OR v_res > MAX_RESOLUTION THEN
        RAISE_APPLICATION_ERROR(
            ERR_INVALID_RES,
            'Invalid resolution: must be between '
                || MIN_RESOLUTION || ' and ' || MAX_RESOLUTION
        );
    END IF;

    -- Extract schema from output_table for function reference
    IF INSTR(output_table, '.') > 0 THEN
        v_schema := SUBSTR(output_table, 1, INSTR(output_table, '.') - 1);
    ELSE
        v_schema := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
    END IF;

    -- Build CTAS using JSON_TABLE to unnest the polyfill results
    -- The input_query must have a column named 'geom' of type SDO_GEOMETRY
    v_sql := 'CREATE TABLE ' || output_table || ' AS '
        || 'SELECT jt.h3, i.* FROM '
        || '(' || input_query || ') i, '
        || 'JSON_TABLE('
        || v_schema || '."__H3_POLYFILL_MODE"'
        || '(i.geom, ' || v_res || ', ''' || v_mode || '''), '
        || '''$[*]'' COLUMNS (h3 VARCHAR2(16) PATH ''$'')) jt';

    EXECUTE IMMEDIATE v_sql;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END H3_POLYFILL_TABLE;
/
