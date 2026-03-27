----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION `@@BQ_DATASET@@.S2_TOTOKEN`
(id INT64)
RETURNS STRING
AS ((
    -- Build full 16-char hex then strip trailing zeros to produce a standard S2 token,
    -- matching the format used by the S2 reference library and other cloud implementations.
    SELECT REGEXP_REPLACE(
        STRING_AGG(FORMAT('%02x', id >> (byte * 8) & 0xff), '' ORDER BY byte DESC),
        '0+$', ''
    )
    FROM UNNEST(GENERATE_ARRAY(0, 7)) AS byte
));
