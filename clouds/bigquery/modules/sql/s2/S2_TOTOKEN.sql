----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

-- from https://stackoverflow.com/a/51600210
CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_TOTOKEN`
(id INT64)
RETURNS STRING
AS ((
    SELECT STRING_AGG(FORMAT('%02x', id >> (byte * 8) & 0xff), '' ORDER BY byte DESC)
    FROM UNNEST(GENERATE_ARRAY(0, 7)) AS byte
));