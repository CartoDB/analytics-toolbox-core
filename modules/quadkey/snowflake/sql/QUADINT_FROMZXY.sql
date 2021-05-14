----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@quadkey.QUADINT_FROMZXY
(z INT, x INT, y INT)
RETURNS BIGINT
AS $$
    BITOR(BITOR(BITAND(Z, 31), BITSHIFTLEFT(X, 5)), BITSHIFTLEFT(Y, Z + 5))
$$;