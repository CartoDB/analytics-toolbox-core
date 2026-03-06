----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

-- Validates whether a given BIGINT is a valid quadbin index by checking
-- the header bit, mode, zoom level, and unused trailing bits.
--
-- Constants:
--   4611686018427387904 = 0x4000000000000000 (header)
--   4503599627370495    = 0xFFFFFFFFFFFFF (unused bits mask)

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_ISVALID
(quadbin BIGINT)
RETURNS BOOLEAN
RETURN (
    CASE WHEN quadbin IS NULL THEN FALSE
    ELSE (
        WITH __params AS (
            SELECT
                (quadbin >> 59) & 7 AS mode,
                (quadbin >> 52) & CAST(31 AS BIGINT) AS z,
                CAST(4611686018427387904 AS BIGINT) AS header,
                CAST(4503599627370495 AS BIGINT)
                    >> (CAST((quadbin >> 52) & 31 AS INT) * 2) AS unused
        )
        SELECT
            quadbin >= 0
            AND (quadbin & header) = header
            AND mode IN (0, 1, 2, 3, 4, 5, 6)
            AND z >= 0
            AND z <= 26
            AND (quadbin & unused) = unused
        FROM __params
    )
    END
);
