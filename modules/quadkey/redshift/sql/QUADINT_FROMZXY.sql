----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_PREFIX@@quadkey.QUADINT_FROMZXY
(INT, INT, INT)
-- (z, x, y)
RETURNS BIGINT
IMMUTABLE
AS $$
    SELECT ($1::BIGINT & 31) | ($2::BIGINT << 5) | ($3::BIGINT << ($1 + 5))
$$ LANGUAGE sql;