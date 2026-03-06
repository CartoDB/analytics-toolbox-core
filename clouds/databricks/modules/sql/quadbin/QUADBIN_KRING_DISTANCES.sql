----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns all quadbin cell indexes and their Chebyshev distances in a
-- filled square k-ring centered at the origin.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS ARRAY<STRUCT<index: BIGINT, distance: INT>>
RETURN (
    IF(
        origin IS NULL OR size IS NULL, NULL,
        (WITH __tile_raw AS (
            SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(origin) AS t
        ),

        __tile AS (
            SELECT
                t.z AS tz,
                t.x AS tx,
                t.y AS ty
            FROM __tile_raw
        ),

        __offsets AS (
            SELECT EXPLODE(SEQUENCE(-size, size)) AS d
        ),

        __neighbors AS (
            SELECT
                __tile.tz,
                (__tile.tx + dx.d + (1 << __tile.tz)) % (1 << __tile.tz) AS nx,
                __tile.ty + dy.d AS ny,
                GREATEST(ABS(dx.d), ABS(dy.d)) AS distance
            FROM __tile
            CROSS JOIN __offsets AS dx
            CROSS JOIN __offsets AS dy
            WHERE __tile.ty + dy.d >= 0 AND __tile.ty + dy.d < (1 << __tile.tz)
        )

        SELECT
            COLLECT_LIST(
                NAMED_STRUCT(
                    'index', @@DB_SCHEMA@@.QUADBIN_FROMZXY(tz, nx, ny),
                    'distance', distance
                )
            )
        FROM __neighbors)
    )
);
