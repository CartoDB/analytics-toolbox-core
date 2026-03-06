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
    IF(quadbin IS NULL OR direction IS NULL, NULL,
        IF(direction NOT IN ('left', 'right', 'up', 'down'),
            RAISE_ERROR('Wrong direction argument passed to sibling'),
            (WITH __tile AS (
                SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(quadbin) AS t
            ),
            __delta AS (
                SELECT
                    t.z AS z, t.x AS x, t.y AS y,
                    CASE direction
                        WHEN 'left' THEN -1 WHEN 'right' THEN 1 ELSE 0
                    END AS dx,
                    CASE direction
                        WHEN 'up' THEN -1 WHEN 'down' THEN 1 ELSE 0
                    END AS dy
                FROM __tile
            ),
            __new_tile AS (
                SELECT
                    z,
                    CASE WHEN x + dx < 0 THEN (x + dx) + (1 << z)
                        ELSE (x + dx) % (1 << z)
                    END AS new_x,
                    y + dy AS new_y
                FROM __delta
            )
            SELECT IF(new_y < 0 OR new_y >= (1 << z), NULL,
                @@DB_SCHEMA@@.QUADBIN_FROMZXY(z, new_x, new_y))
            FROM __new_tile)
        )
    )
);
