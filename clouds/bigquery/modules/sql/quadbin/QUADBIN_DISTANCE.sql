----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_DISTANCE`
(origin INT64, destination INT64)
RETURNS INT64
AS ((
    IF(origin IS NULL OR destination IS NULL,
        NULL,
        (WITH __quadbin_coords AS (
        SELECT
            `@@BQ_DATASET@@.QUADBIN_TOZXY`(origin) AS origin_coords,
            `@@BQ_DATASET@@.QUADBIN_TOZXY`(destination) AS destination_coords
        )
        SELECT IF(origin_coords.z != destination_coords.z,
            NULL,
            GREATEST(
                ABS(destination_coords.x - origin_coords.x),
                ABS(destination_coords.y - origin_coords.y)
            )
        )
        FROM __quadbin_coords)
    )
));
