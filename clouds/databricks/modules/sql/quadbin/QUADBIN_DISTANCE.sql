----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the Chebyshev distance between two quadbin indexes.
-- Both must have the same resolution; otherwise returns NULL.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_DISTANCE
(origin BIGINT, destination BIGINT)
RETURNS BIGINT
RETURN (
    IF(origin IS NULL OR destination IS NULL, NULL,
        (WITH __coords AS (
            SELECT
                @@DB_SCHEMA@@.QUADBIN_TOZXY(origin) AS o,
                @@DB_SCHEMA@@.QUADBIN_TOZXY(destination) AS d
        )
        SELECT IF(o.z != d.z, NULL,
            CAST(GREATEST(ABS(d.x - o.x), ABS(d.y - o.y)) AS BIGINT)
        )
        FROM __coords)
    )
);
