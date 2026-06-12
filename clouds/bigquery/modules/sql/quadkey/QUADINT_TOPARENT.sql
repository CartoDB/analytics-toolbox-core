----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADINT_TOPARENT`
(quadint INT64, resolution INT64)
RETURNS INT64
AS ((
    IF(resolution IS NULL OR resolution < 0 OR quadint IS NULL,
        ERROR('QUADINT_TOPARENT receiving wrong arguments'),

        (
            WITH zxycontext AS (
                SELECT `@@BQ_DATASET@@.QUADINT_TOZXY`(
                        quadint
                    ) AS zxy
            )

            SELECT `@@BQ_DATASET@@.QUADINT_FROMZXY`(
                    resolution,
                    zxy.x >> (zxy.z - resolution),
                    zxy.y >> (zxy.z - resolution)
                )
            FROM zxycontext
        )
    )
));
