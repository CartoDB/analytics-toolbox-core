----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.__QUADBIN_INT_TOSTRING`
(quadbin INT64)
RETURNS STRING
AS ((
    SELECT FORMAT('%x', quadbin)
));
