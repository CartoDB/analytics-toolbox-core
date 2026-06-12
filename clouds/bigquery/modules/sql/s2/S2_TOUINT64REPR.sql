----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_TOUINT64REPR`
(id INT64)
RETURNS STRING
AS (
    IF(id < 0,
        IF(id < -8446744073709551616,
            CONCAT(
                "9",
                FORMAT(
                    "%018d", 1000000000000000000 + (8446744073709551616 + id)
                )
            ),
            CONCAT("1", FORMAT("%019d", 8446744073709551616 + id))
        ),
        CAST(id AS STRING))
);
