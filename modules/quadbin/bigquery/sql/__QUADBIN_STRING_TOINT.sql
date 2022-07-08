----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@carto.__QUADBIN_STRING_TOINT`
(quadbin STRING)
RETURNS INT64
AS ((
    SELECT CAST(CONCAT('0x', quadbin) AS INT64)
));