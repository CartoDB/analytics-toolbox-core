----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_BBOX
(quadbin INT)
RETURNS ARRAY
AS $$
    CASE
        WHEN quadbin IS NULL THEN
            NULL
        ELSE ( 
            WITH
            __zxy AS (
                SELECT
                    QUADBIN_TOZXY(quadbin) AS tile,
                    ACOS(-1) AS PI
            )
            SELECT ARRAY_CONSTRUCT(
                180 * (2.0 * tile:x / CAST(BITSHIFTLEFT(1, tile:z) AS FLOAT) - 1.0),
                360 * (ATAN(EXP(-(2.0 * (tile:y + 1) / CAST(BITSHIFTLEFT(1, tile:z) AS FLOAT) - 1) * PI)) / PI - 0.25),
                180 * (2.0 * (tile:x + 1) / CAST(BITSHIFTLEFT(1, tile:z) AS FLOAT) - 1.0),
                360 * (ATAN(EXP(-(2.0 * tile:y / CAST(BITSHIFTLEFT(1, tile:z) AS FLOAT) - 1) * PI)) / PI - 0.25)
            )
            FROM __zxy
        )
    END
$$;