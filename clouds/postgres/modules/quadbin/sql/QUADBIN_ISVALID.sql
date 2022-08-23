----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_ISVALID(
  quadbin BIGINT
)
RETURNS BOOLEAN
 AS
$BODY$
    SELECT CASE
        WHEN quadbin IS NULL THEN
            FALSE
        ELSE (
            WITH
            __params AS (
                SELECT
                    ((quadbin >> 59) & 7)::INT AS mode,
                    ((quadbin >> 52) & 31)::INT AS z,
                    4611686018427387904 AS header,
                    (4503599627370495 >> (((quadbin >> 52) & 31)::INT << 1)) AS unused
            )
            SELECT
                quadbin >= 0
                AND (quadbin & header = header)
                AND mode IN (0,1,2,3,4,5,6)
                AND z >= 0
                AND z <= 26
                AND (quadbin & unused = unused)
            FROM __params
        )
    END
$BODY$
  LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
