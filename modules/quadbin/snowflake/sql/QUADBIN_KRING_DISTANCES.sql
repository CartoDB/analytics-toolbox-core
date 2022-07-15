----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

-- FIXME: slow

CREATE OR REPLACE FUNCTION QUADBIN_KRING_DISTANCES
(origin BIGINT, size INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    _QUADBIN_KRING(TO_VARCHAR(ORIGIN, 'xxxxxxxxxxxxxxxx'), SIZE, true)
$$;