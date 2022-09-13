----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADINT_FROMZXY
(INT, INT, INT)
-- (z, x, y)
RETURNS BIGINT
STABLE
AS $$
    SELECT ($1::BIGINT & 31) | ($2::BIGINT << 5) | ($3::BIGINT << ($1 + 5))
$$ LANGUAGE SQL;
