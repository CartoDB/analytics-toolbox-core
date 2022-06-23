----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_CENTER(quadbin INT)
RETURNS GEOGRAPHY
AS $$
    CASE
        WHEN quadbin IS NULL THEN
            NULL
        -- Deal with level 0 boundary issue.
        WHEN quadbin=5188146770730811392 THEN
            ST_POINT(0,0)
        -- Deal with level 1. Prevent error from antipodal vertices.
        WHEN quadbin=5193776270265024511 THEN
            ST_POINT(-90,45)
        WHEN quadbin=5194902170171867135 THEN
            ST_POINT(90,45)
        WHEN quadbin=5196028070078709759 THEN
            ST_POINT(-90,-45)
        WHEN quadbin=5197153969985552383 THEN
            ST_POINT(90,-45)
        ELSE (
            WITH
            __zxy AS (
                SELECT
                    QUADBIN_TOZXY(quadbin) AS tile,
                    ACOS(-1) AS PI
            )
            SELECT ST_POINT(
                180 * (2.0 * (tile:x + 0.5) / CAST(BITSHIFTLEFT(1, tile:z) AS FLOAT) - 1.0),
                360 * (ATAN(EXP(-(2.0 * (tile:y + 0.5) / CAST(BITSHIFTLEFT(1, tile:z) AS FLOAT) - 1) * PI)) / PI - 0.25)
            )
            FROM __zxy
        )
    END
$$;
