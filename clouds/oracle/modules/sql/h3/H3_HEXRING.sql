----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_HEXRING
(
    origin VARCHAR2, distance NUMBER
)
RETURN @@ORA_SCHEMA@@.H3_INDEX_ARRAY PIPELINED
IS
    -- Constants
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    SRID_WGS84 CONSTANT PLS_INTEGER := 4326;
    POINT_GTYPE CONSTANT PLS_INTEGER := 2001;
    MIDPOINT_DIVISOR CONSTANT NUMBER := 2;
    NUDGE_FACTOR CONSTANT NUMBER := 0.00001;

    -- Working variables
    h3_raw RAW(8);
    is_valid BOOLEAN;
    cell_res PLS_INTEGER;
    dist PLS_INTEGER;

    -- Associative array: visited cells -> distance
    TYPE visited_map IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(16);
    visited visited_map;

    -- Frontier lists (cells at current BFS distance)
    TYPE str_array IS TABLE OF VARCHAR2(16) INDEX BY PLS_INTEGER;
    frontier str_array;
    next_frontier str_array;
    frontier_count PLS_INTEGER;
    next_count PLS_INTEGER;

    -- Neighbor-finding variables
    v_boundary SDO_GEOMETRY;
    v_center SDO_GEOMETRY;
    v_ords SDO_ORDINATE_ARRAY;
    v_num_edges PLS_INTEGER;
    center_lon NUMBER;
    center_lat NUMBER;
    mid_lon NUMBER;
    mid_lat NUMBER;
    dx NUMBER;
    dy NUMBER;
    edge_dist NUMBER;
    mid_point SDO_GEOMETRY;
    neighbor_raw RAW(8);
    neighbor_hex VARCHAR2(16);
    cell_raw RAW(8);
    v_key VARCHAR2(16);
BEGIN
    -- NULL inputs -> empty result
    IF origin IS NULL OR distance IS NULL THEN
        RETURN;
    END IF;

    dist := TRUNC(distance);
    IF dist < 0 THEN
        RETURN;
    END IF;

    -- Validate H3 origin
    BEGIN
        h3_raw := HEXTORAW(LPAD(origin, RAW_BYTE_LENGTH, '0'));
        is_valid := SDO_UTIL.H3_IS_VALID_CELL(h3_raw);
        IF NOT is_valid THEN
            RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN;
    END;

    cell_res := SDO_UTIL.H3_RESOLUTION(h3_raw);

    -- Special case: distance 0 returns just the origin
    -- Matches H3 library gridRing(_, 0) behavior in this repo's other clouds
    IF dist = 0 THEN
        PIPE ROW(LOWER(origin));
        RETURN;
    END IF;

    -- Initialize BFS: origin at distance 0
    visited(LOWER(origin)) := 0;
    frontier(1) := LOWER(origin);
    frontier_count := 1;

    FOR d IN 1 .. dist LOOP
        next_count := 0;

        FOR f IN 1 .. frontier_count LOOP
            cell_raw := HEXTORAW(LPAD(frontier(f), RAW_BYTE_LENGTH, '0'));
            v_boundary := SDO_UTIL.H3_BOUNDARY(cell_raw);
            v_center := SDO_UTIL.H3_CENTER(cell_raw);
            v_ords := v_boundary.SDO_ORDINATES;
            center_lon := v_center.SDO_POINT.X;
            center_lat := v_center.SDO_POINT.Y;
            v_num_edges := (v_ords.COUNT / 2) - 1;

            FOR e IN 1 .. v_num_edges LOOP
                mid_lon := (v_ords(2 * e - 1) + v_ords(2 * e + 1)) / MIDPOINT_DIVISOR;
                mid_lat := (v_ords(2 * e) + v_ords(2 * e + 2)) / MIDPOINT_DIVISOR;

                dx := mid_lon - center_lon;
                dy := mid_lat - center_lat;
                edge_dist := SQRT(dx * dx + dy * dy);
                IF edge_dist > 0 THEN
                    mid_lon := mid_lon + NUDGE_FACTOR * (dx / edge_dist);
                    mid_lat := mid_lat + NUDGE_FACTOR * (dy / edge_dist);
                END IF;

                mid_point := SDO_GEOMETRY(
                    POINT_GTYPE, SRID_WGS84,
                    SDO_POINT_TYPE(mid_lon, mid_lat, NULL),
                    NULL, NULL
                );

                neighbor_raw := SDO_UTIL.H3_KEY(mid_point, cell_res);
                neighbor_hex := LOWER(LTRIM(RAWTOHEX(neighbor_raw), '0'));

                IF NOT visited.EXISTS(neighbor_hex) THEN
                    visited(neighbor_hex) := d;
                    next_count := next_count + 1;
                    next_frontier(next_count) := neighbor_hex;
                END IF;
            END LOOP;
        END LOOP;

        frontier.DELETE;
        frontier_count := next_count;
        FOR i IN 1 .. frontier_count LOOP
            frontier(i) := next_frontier(i);
        END LOOP;
        next_frontier.DELETE;
    END LOOP;

    -- Pipe out only cells at exactly the target distance
    v_key := visited.FIRST;
    WHILE v_key IS NOT NULL LOOP
        IF visited(v_key) = dist THEN
            PIPE ROW(v_key);
        END IF;
        v_key := visited.NEXT(v_key);
    END LOOP;

    RETURN;
EXCEPTION
    WHEN NO_DATA_NEEDED THEN
        RETURN;
END H3_HEXRING;
/
