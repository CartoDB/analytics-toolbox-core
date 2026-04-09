----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_POLYFILL
(
    geom SDO_GEOMETRY, resolution NUMBER
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

    -- Geometry type constants (from SDO_GEOMETRY.GET_GTYPE())
    GTYPE_POLYGON CONSTANT PLS_INTEGER := 3;
    GTYPE_MULTIPOLYGON CONSTANT PLS_INTEGER := 7;
    GTYPE_COLLECTION CONSTANT PLS_INTEGER := 4;

    -- H3 average edge lengths in meters by resolution (from h3geo.org)
    TYPE edge_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    edge_lengths edge_array;

    -- Working variables
    res PLS_INTEGER;
    gtype PLS_INTEGER;
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
    h3_center SDO_GEOMETRY;
    center_point SDO_GEOMETRY;
    geom_srid PLS_INTEGER;

    -- Oversample factor: sample at fraction of edge length to catch all cells
    OVERSAMPLE_FACTOR CONSTANT NUMBER := 0.35;
    -- Meters per degree of latitude (approximate)
    METERS_PER_DEGREE CONSTANT NUMBER := 111320;

    -- Associative array for deduplication of candidate cells
    TYPE cell_map IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(16);
    candidates cell_map;

    -- For sorting via associative array (natural key order)
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

    -- Only polygon types are supported
    gtype := geom.GET_GTYPE();
    IF gtype NOT IN (GTYPE_POLYGON, GTYPE_MULTIPOLYGON, GTYPE_COLLECTION) THEN
        RETURN NULL;
    END IF;

    -- Track the input SRID so we can match it on H3 center points.
    -- SDO_UTIL.H3_CENTER returns SRID 4326, but input may have NULL SRID
    -- (e.g. from SDO_UTIL.FROM_WKTGEOMETRY). SDO_GEOM.RELATE requires
    -- both geometries to have the same SRID.
    geom_srid := geom.SDO_SRID;

    -- Initialize H3 average edge lengths (meters) from the reference table
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

    -- Get the edge length for the target resolution
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
    -- Sample at OVERSAMPLE_FACTOR * edge_length to ensure every cell
    -- gets at least one sample point
    center_lat := (south + north) / 2;
    cos_lat := COS(center_lat * 3.14159265358979323846 / 180);
    IF cos_lat < 0.01 THEN
        cos_lat := 0.01;
    END IF;

    step_lat := (edge_m * OVERSAMPLE_FACTOR) / METERS_PER_DEGREE;
    step_lon := step_lat / cos_lat;

    -- Ensure at least a minimal step to avoid infinite loops
    IF step_lat < 0.0000001 THEN
        step_lat := 0.0000001;
    END IF;
    IF step_lon < 0.0000001 THEN
        step_lon := 0.0000001;
    END IF;

    -- Phase 1: Generate sample points across the bbox and collect candidate cells
    -- Extend bbox by one step in each direction to catch edge cells
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
                    NULL; -- Skip invalid sample points
            END;
            grid_lon := grid_lon + step_lon;
        END LOOP;
        grid_lat := grid_lat + step_lat;
    END LOOP;

    -- Phase 2: Filter candidates by center-in-geometry check
    v_key := candidates.FIRST;
    WHILE v_key IS NOT NULL LOOP
        BEGIN
            cell_raw := HEXTORAW(LPAD(v_key, RAW_BYTE_LENGTH, '0'));
            -- Get center from H3 (returns SRID 4326) and re-create
            -- with the input geometry's SRID to avoid RELATE mismatch
            h3_center := SDO_UTIL.H3_CENTER(cell_raw);
            center_point := SDO_GEOMETRY(
                POINT_GTYPE, geom_srid,
                SDO_POINT_TYPE(
                    h3_center.SDO_POINT.X,
                    h3_center.SDO_POINT.Y,
                    NULL
                ),
                NULL, NULL
            );
            relates_result := SDO_GEOM.RELATE(
                center_point,
                'ANYINTERACT',
                geom,
                TOLERANCE
            );
            IF relates_result = 'TRUE' THEN
                result_map(v_key) := 1;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Skip cells that fail the relate check
        END;
        v_key := candidates.NEXT(v_key);
    END LOOP;

    -- Phase 3: Build sorted JSON array
    -- Associative arrays indexed by VARCHAR2 iterate in key order
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

    -- Return NULL instead of empty array for consistency with other clouds
    IF result_map.COUNT = 0 THEN
        RETURN NULL;
    END IF;

    RETURN json_result;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END H3_POLYFILL;
/
