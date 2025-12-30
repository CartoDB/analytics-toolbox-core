--------------------------------
-- Copyright (C) 2021-2025 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADINT_TOCHILDREN
(BIGINT, INT)
-- (quadint, resolution)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse(@@RS_SCHEMA@@.__QUADINT_TOCHILDREN($1, $2))
$$ LANGUAGE sql;
