----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.QUADBIN_BBOX`
(quadbin INT64)
RETURNS ARRAY<FLOAT64>
AS (
    CASE quadbin
        WHEN NULL THEN
            NULL
        ELSE (
            WITH
            __zxy AS (
                SELECT
                    `@@BQ_DATASET@@.QUADBIN_TOZXY`(
                        quadbin
                    ) AS tile,
                    ACOS(-1) AS pi
            )

            SELECT [
                180 * (2.0 * tile.x / CAST((1 << tile.z) AS FLOAT64) - 1.0),
                360 * (
                    ATAN(
                        EXP(
                            -(
                                2.0 * (
                                    tile.y + 1
                                ) / CAST((1 << tile.z) AS FLOAT64) - 1
                            ) * pi
                        )
                    ) / pi - 0.25
                ),
                180 * (
                    2.0 * (tile.x + 1) / CAST((1 << tile.z) AS FLOAT64) - 1.0
                ),
                360 * (
                    ATAN(
                        EXP(
                            -(
                                2.0 * tile.y / CAST(
                                    (1 << tile.z) AS FLOAT64
                                ) - 1
                            ) * pi
                        )
                    ) / pi - 0.25
                )
            ]
            FROM __zxy
        )
    END
);
