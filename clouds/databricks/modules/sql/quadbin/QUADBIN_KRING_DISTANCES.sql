----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all quadbin cell indexes and their Chebyshev distances in a
-- filled square k-ring centered at the origin.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS ARRAY<STRUCT<index: BIGINT, distance: INT>>
RETURN (
    IF(origin IS NULL OR size IS NULL, NULL,
        (WITH __tile AS (
            SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(origin) AS t
        ),
        __offsets AS (
            SELECT EXPLODE(SEQUENCE(-size, size)) AS d
        ),
        __neighbors AS (
            SELECT
                t.z AS z,
                (t.x + dx.d + (1 << t.z)) % (1 << t.z) AS nx,
                t.y + dy.d AS ny,
                GREATEST(ABS(dx.d), ABS(dy.d)) AS distance
            FROM __tile
            CROSS JOIN __offsets dx
            CROSS JOIN __offsets dy
            WHERE t.y + dy.d >= 0 AND t.y + dy.d < (1 << t.z)
        )
        SELECT COLLECT_LIST(
            NAMED_STRUCT(
                'index', @@DB_SCHEMA@@.QUADBIN_FROMZXY(z, nx, ny),
                'distance', distance
            )
        )
        FROM __neighbors)
    )
);
