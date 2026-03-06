----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the adjacent quadbin in a given direction (left/right/up/down).
-- Wraps around on the x-axis; returns NULL if the sibling is out of
-- bounds on the y-axis.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_SIBLING
(quadbin BIGINT, direction STRING)
RETURNS BIGINT
RETURN (
    IF(
        quadbin IS NULL OR direction IS NULL, NULL,
        IF(
            direction NOT IN ('left', 'right', 'up', 'down'),
            RAISE_ERROR('Wrong direction argument passed to sibling'),
            (WITH __tile_raw AS (
                SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(quadbin) AS t
            ),

            __tile AS (
                SELECT
                    t.z AS tz,
                    t.x AS tx,
                    t.y AS ty
                FROM __tile_raw
            ),

            __dir AS (
                SELECT
                    CASE direction
                        WHEN 'left' THEN -1 WHEN 'right' THEN 1 ELSE 0
                    END AS dx,
                    CASE direction
                        WHEN 'up' THEN -1 WHEN 'down' THEN 1 ELSE 0
                    END AS dy
            ),

            __new_tile AS (
                SELECT
                    __tile.tz,
                    CASE
                        WHEN __tile.tx + __dir.dx < 0
                            THEN (__tile.tx + __dir.dx) + (1 << __tile.tz)
                        ELSE (__tile.tx + __dir.dx) % (1 << __tile.tz)
                    END AS new_x,
                    __tile.ty + __dir.dy AS new_y
                FROM __tile
                CROSS JOIN __dir
            )

            SELECT
                IF(
                    new_y < 0 OR new_y >= (1 << tz), NULL,
                    @@DB_SCHEMA@@.QUADBIN_FROMZXY(tz, new_x, new_y)
                )
            FROM __new_tile)
        )
    )
);
