----------------------------
-- Copyright (C) 2022-2023 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_BBOX
(quadbin BIGINT)
RETURNS ARRAY
IMMUTABLE
AS $$
    CASE quadbin
        WHEN NULL THEN
            NULL
        ELSE (
            WITH
            __zxy AS (
                SELECT
                    @@SF_SCHEMA@@.QUADBIN_TOZXY(
                        quadbin
                    ) AS tile,
                    ACOS(-1) AS pi
            )
            SELECT [
                180 * (2.0 * tile:x / BITSHIFTLEFT(1, tile:z)::FLOAT8 - 1.0),
                360 * (
                    ATAN(
                        EXP(
                            -(
                                2.0 * (
                                    tile:y + 1
                                ) / BITSHIFTLEFT(1, tile:z)::FLOAT8 - 1
                            ) * pi
                        )
                    ) / pi - 0.25
                ),
                180 * (
                    2.0 * (tile:x + 1) / BITSHIFTLEFT(1, tile:z)::FLOAT8 - 1.0
                ),
                360 * (
                    ATAN(
                        EXP(
                            -( 2.0 * tile:y / BITSHIFTLEFT(1, tile:z)::FLOAT8 - 1
                             ) * pi
                        )
                    ) / pi - 0.25
                )
            ]    
            FROM __zxy
        )
    END
$$;
