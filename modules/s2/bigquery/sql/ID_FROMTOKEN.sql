----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

-- from https://stackoverflow.com/a/51600210
CREATE OR REPLACE FUNCTION `@@BQ_PREFIX@@s2.ID_FROMTOKEN`
(token STRING)
RETURNS INT64
AS ((
    SELECT SUM(CAST(CONCAT('0x', SUBSTR(token, byte * 2 + 1, 2)) AS INT64) << ((LENGTH(token) - (byte + 1) * 2) * 4))
   FROM UNNEST(GENERATE_ARRAY(1, LENGTH(token) / 2)) WITH OFFSET byte
));
