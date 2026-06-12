----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_FROMTOKEN`
(token STRING)
RETURNS INT64
AS ((
    -- Pad to 16 hex chars (right-pad with zeros) to restore trailing zero nibbles
    -- that S2 tokens strip, then process all 8 bytes. Works with both standard
    -- variable-length S2 tokens (e.g. '0d423') and full 16-char tokens (e.g. '0d42300000000000').
    SELECT SUM(CAST(CONCAT('0x', SUBSTR(RPAD(token, 16, '0'), b * 2 + 1, 2)) AS INT64) << ((7 - b) * 8))
    FROM UNNEST(GENERATE_ARRAY(0, 7)) AS b
));
