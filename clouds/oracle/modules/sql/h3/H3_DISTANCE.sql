----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@ORA_SCHEMA@@.H3_DISTANCE
(
    origin VARCHAR2, destination VARCHAR2
)
RETURN NUMBER
DETERMINISTIC
IS
    -- Constants
    RAW_BYTE_LENGTH CONSTANT PLS_INTEGER := 16;
    SRID_WGS84 CONSTANT PLS_INTEGER := 4326;
    POINT_GTYPE CONSTANT PLS_INTEGER := 2001;
    MIDPOINT_DIVISOR CONSTANT NUMBER := 2;
    -- Small offset (~1m) to push edge midpoints out of the origin cell
    -- so H3_KEY resolves them to the neighboring cell
    NUDGE_FACTOR CONSTANT NUMBER := 0.00001;
    -- Safety cap to avoid runaway BFS on unreachable or distant cells
    MAX_DISTANCE CONSTANT PLS_INTEGER := 100;

    -- Working variables
    origin_raw RAW(8);
    dest_raw RAW(8);
    is_valid BOOLEAN;
    origin_res PLS_INTEGER;
    dest_res PLS_INTEGER;

    -- BFS data structures
    TYPE visited_set IS TABLE OF BOOLEAN INDEX BY VARCHAR2(16);
    visited visited_set;

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
BEGIN
    -- NULL inputs -> NULL
    IF origin IS NULL OR destination IS NULL THEN
        RETURN NULL;
    END IF;

    -- Validate origin
    BEGIN
        origin_raw := HEXTORAW(LPAD(origin, RAW_BYTE_LENGTH, '0'));
        is_valid := SDO_UTIL.H3_IS_VALID_CELL(origin_raw);
        IF NOT is_valid THEN
            RETURN NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END;

    -- Validate destination
    BEGIN
        dest_raw := HEXTORAW(LPAD(destination, RAW_BYTE_LENGTH, '0'));
        is_valid := SDO_UTIL.H3_IS_VALID_CELL(dest_raw);
        IF NOT is_valid THEN
            RETURN NULL;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END;

    -- Both cells must be at the same resolution
    origin_res := SDO_UTIL.H3_RESOLUTION(origin_raw);
    dest_res := SDO_UTIL.H3_RESOLUTION(dest_raw);
    IF origin_res != dest_res THEN
        RETURN NULL;
    END IF;

    -- Same cell -> distance 0
    IF origin = destination THEN
        RETURN 0;
    END IF;

    -- BFS: expand from origin until destination is found
    visited(origin) := TRUE;
    frontier(1) := origin;
    frontier_count := 1;

    FOR d IN 1 .. MAX_DISTANCE LOOP
        next_count := 0;

        FOR f IN 1 .. frontier_count LOOP
            -- Get boundary and center of current frontier cell
            cell_raw := HEXTORAW(LPAD(frontier(f), RAW_BYTE_LENGTH, '0'));
            v_boundary := SDO_UTIL.H3_BOUNDARY(cell_raw);
            v_center := SDO_UTIL.H3_CENTER(cell_raw);
            v_ords := v_boundary.SDO_ORDINATES;
            center_lon := v_center.SDO_POINT.X;
            center_lat := v_center.SDO_POINT.Y;
            -- Number of edges = (number of coordinate pairs) - 1
            -- because the polygon ring is closed (first vertex repeated)
            v_num_edges := (v_ords.COUNT / 2) - 1;

            -- For each edge, compute midpoint nudged away from center
            FOR e IN 1 .. v_num_edges LOOP
                mid_lon := (v_ords(2 * e - 1) + v_ords(2 * e + 1)) / MIDPOINT_DIVISOR;
                mid_lat := (v_ords(2 * e) + v_ords(2 * e + 2)) / MIDPOINT_DIVISOR;

                -- Nudge the midpoint away from the cell center so that
                -- H3_KEY resolves it to the neighbor, not back to self
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

                neighbor_raw := SDO_UTIL.H3_KEY(mid_point, origin_res);
                neighbor_hex := LOWER(LTRIM(RAWTOHEX(neighbor_raw), '0'));

                -- Found the destination
                IF neighbor_hex = destination THEN
                    RETURN d;
                END IF;

                -- Add to frontier if not already visited
                IF NOT visited.EXISTS(neighbor_hex) THEN
                    visited(neighbor_hex) := TRUE;
                    next_count := next_count + 1;
                    next_frontier(next_count) := neighbor_hex;
                END IF;
            END LOOP;
        END LOOP;

        -- Swap frontiers
        frontier.DELETE;
        frontier_count := next_count;
        FOR i IN 1 .. frontier_count LOOP
            frontier(i) := next_frontier(i);
        END LOOP;
        next_frontier.DELETE;

        -- Empty frontier means disconnected (shouldn't happen on H3 grid)
        IF frontier_count = 0 THEN
            RETURN NULL;
        END IF;
    END LOOP;

    -- Exceeded max distance
    RETURN NULL;
END H3_DISTANCE;
/
