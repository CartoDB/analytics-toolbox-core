----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Returns the boundary of a quadbin tile as a GEOMETRY(4326) POLYGON.

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS GEOMETRY(4326)
RETURN (
    IF(
        quadbin IS NULL, CAST(NULL AS GEOMETRY(4326)),
        (WITH __bbox AS (
            SELECT @@DB_SCHEMA@@.QUADBIN_BBOX(quadbin) AS b
        )

        SELECT
            ST_SETSRID(ST_GEOMFROMTEXT(
                FORMAT_STRING(
                    'POLYGON((%s %s,%s %s,%s %s,%s %s,%s %s))',
                    b[0], b[1], b[0], b[3], b[2], b[3], b[2], b[1], b[0], b[1]
                )
            ), 4326)
        FROM __bbox)
    )
);
