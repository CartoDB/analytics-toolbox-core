----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the boundary of a quadbin tile as a WKT POLYGON string.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS STRING
RETURN (
    IF(
        quadbin IS NULL, NULL,
        (WITH __bbox AS (
            SELECT @@DB_SCHEMA@@.QUADBIN_BBOX(quadbin) AS b
        )

        SELECT
            FORMAT_STRING(
                'POLYGON((%s %s,%s %s,%s %s,%s %s,%s %s))',
                b[0], b[1], b[0], b[3], b[2], b[3], b[2], b[1], b[0], b[1]
            )
        FROM __bbox)
    )
);
