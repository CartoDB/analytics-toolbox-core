--------------------------------
-- Copyright (C) 2022-2024 CARTO
--------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_FROMLONGLAT
(longitude FLOAT, latitude FLOAT, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    IFF(longitude IS NULL OR latitude IS NULL OR resolution IS NULL,
        NULL,
        IFF (resolution < 0 OR resolution > 26,
            NULL, (
            WITH
            __params AS (
                SELECT
                    resolution AS z,
                    ACOS(-1) AS PI,
                    GREATEST(-89, LEAST(89, latitude)) AS params_latitude
            ),
            __zxy AS (
                SELECT
                    z,
                    BITAND( CAST(FLOOR(BITSHIFTLEFT(1, z) * ((longitude / 360.0) + 0.5)) AS INT), (BITSHIFTLEFT(1, z) - 1)) AS x,
                    BITAND( CAST(FLOOR(GREATEST(0, LEAST(BITSHIFTLEFT(1, z) - 1, BITSHIFTLEFT(1, z) * (0.5 - (LN(TAN(PI/4.0 + params_latitude/2.0 * PI/180.0)) / (2*PI)))))) AS INT),(BITSHIFTLEFT(1, z) - 1)) AS y
                FROM __params
            )
            SELECT @@SF_SCHEMA@@.QUADBIN_FROMZXY(z, x, y)
            FROM __zxy)
        )
    )
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@._QUADBIN_FROMLONGLAT
(longitude FLOAT, latitude FLOAT, resolution INT)
RETURNS BIGINT
IMMUTABLE
AS $$
    WITH
    __params AS (
        SELECT
            resolution AS z,
            ACOS(-1) AS PI,
            GREATEST(-89, LEAST(89, latitude)) AS params_latitude
    ),
    __zxy AS (
        SELECT
            z,
            BITAND( CAST(FLOOR(BITSHIFTLEFT(1, z) * ((longitude / 360.0) + 0.5)) AS INT), (BITSHIFTLEFT(1, z) - 1)) AS x,
            BITAND( CAST(FLOOR(GREATEST(0, LEAST(BITSHIFTLEFT(1, z) - 1, BITSHIFTLEFT(1, z) * (0.5 - (LN(TAN(PI/4.0 + params_latitude/2.0 * PI/180.0)) / (2*PI)))))) AS INT),(BITSHIFTLEFT(1, z) - 1)) AS y
        FROM __params
    )
    SELECT @@SF_SCHEMA@@._QUADBIN_STRING_TOINT(@@SF_SCHEMA@@._QUADBIN_FROMZXY(z, x, y))
    FROM __zxy
$$;

