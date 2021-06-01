----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.UINT64REPR_FROM_ID`
(id INT64)
RETURNS STRING
AS (
    IF (id < 0,
        IF (id < -8446744073709551616,
            CONCAT("9",format("%018d", 1000000000000000000+(8446744073709551616+id))),
            CONCAT("1",format("%019d", 8446744073709551616+id))
         ),
        CAST(id AS STRING))
);
