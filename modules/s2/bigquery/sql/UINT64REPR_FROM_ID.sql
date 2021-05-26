----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.UINT64REPR_FROM_ID`
(x INT64)
RETURNS STRING
AS (
    IF (x < 0,
        IF (x < -8446744073709551616,
            CONCAT("9",format("%018d", 1000000000000000000+(8446744073709551616+x))),
            CONCAT("1",format("%019d", 8446744073709551616+x))
         ),
        CAST(x AS STRING))
);
