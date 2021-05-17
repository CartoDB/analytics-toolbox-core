----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.ST_BOUNDARY_FROMTOKEN`
(token STRING)
RETURNS GEOGRAPHY
AS ((
    `@@BQ_PREFIX@@s2.ST_BOUNDARY_FROMINT64`(`@@BQ_PREFIX@@s2.INT64_FROMTOKEN`(token))
));
