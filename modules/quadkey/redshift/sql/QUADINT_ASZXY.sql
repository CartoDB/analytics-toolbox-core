----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@carto.QUADINT_ASZXY
(BIGINT)
-- (quadint)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse('{' ||
        '"z": ' || ($1 & 31) || ',' ||
        '"x": ' || (($1 >> 5) & ((1 << ($1 & 31)::INT) - 1)) || ',' ||
        '"y": ' || (($1 >> (5 + ($1 & 31)::INT))) || '}'
        )
$$ language sql;