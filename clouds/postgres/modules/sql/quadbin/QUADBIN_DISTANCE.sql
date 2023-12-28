----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_DISTANCE
(origin BIGINT, destination BIGINT)
RETURNS BIGINT
AS
$BODY$
    SELECT 
        CASE WHEN origin IS NULL OR destination IS NULL THEN
            NULL
        ELSE
            (WITH __quadbin_coords AS (
            SELECT
                @@PG_SCHEMA@@.QUADBIN_TOZXY(origin) AS origin_coords,
                @@PG_SCHEMA@@.QUADBIN_TOZXY(destination) AS destination_coords
            )
            SELECT
                CASE WHEN (origin_coords->>'z')::INT != (destination_coords->>'z')::INT THEN
                    NULL
                ELSE
                    GREATEST(
                        ABS((destination_coords->>'x')::BIGINT - (origin_coords->>'x')::BIGINT),
                        ABS((destination_coords->>'y')::BIGINT - (origin_coords->>'y')::BIGINT)
                    )
                END
            FROM __quadbin_coords
            )
    END
$BODY$
LANGUAGE sql IMMUTABLE PARALLEL SAFE;
