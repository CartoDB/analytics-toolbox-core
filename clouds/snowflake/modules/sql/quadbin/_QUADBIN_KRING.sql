----------------------------
-- Copyright (C) 2022-2023 CARTO
----------------------------


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._QUADBIN_KRING
(index BIGINT, size INT, distanceFlag BOOLEAN)
RETURNS ARRAY
IMMUTABLE
AS $$
    WITH
    __inputTile AS (
        SELECT
            @@SF_SCHEMA@@.QUADBIN_TOZXY(index) inputTile
    ),
    __indexes AS (
        SELECT
            ARRAY_GENERATE_RANGE(-size, size+1) AS dxs,
            ARRAY_GENERATE_RANGE(-size, size+1) AS dys
    ),
    __results AS (
        SELECT
            @@SF_SCHEMA@@.QUADBIN_FROMZXY(
                inputTile:z,
                inputTile:x + dx.value,
                inputTile:y + dy.value) as newindex,
            GREATEST(ABS(dx.value), ABS(dy.value)) as distance
        FROM
            __inputTile,
            __indexes,
            table(flatten( input => dxs)) dx,
            table(flatten( input => dys)) dy
    )
    SELECT
        ARRAY_AGG(
            CASE distanceFlag
                WHEN TRUE THEN
                    '{"distance":' || DISTANCE::STRING || ',"index":' || newindex::STRING || '}'
                ELSE
                    newindex::STRING
            END
        )
    FROM __results
$$;
