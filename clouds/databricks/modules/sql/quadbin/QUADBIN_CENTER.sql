----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the center of a quadbin tile as [longitude, latitude].

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_CENTER
(quadbin BIGINT)
RETURNS ARRAY<DOUBLE>
RETURN (
    IF(
        quadbin IS NULL, NULL,
        (WITH __tile AS (
            SELECT @@DB_SCHEMA@@.QUADBIN_TOZXY(quadbin) AS t
        ),

        __zxy AS (
            SELECT
                t.z,
                t.x,
                t.y,
                CAST(1 << t.z AS DOUBLE) AS num_tiles,
                ACOS(-1) AS pi
            FROM __tile
        )

        SELECT
            ARRAY(
                180.0 * (2.0 * (x + 0.5) / num_tiles - 1.0),
                360.0 * (
                    ATAN(EXP(-(2.0 * (y + 0.5) / num_tiles - 1.0) * pi))
                    / pi - 0.25
                )
            )
        FROM __zxy)
    )
);
