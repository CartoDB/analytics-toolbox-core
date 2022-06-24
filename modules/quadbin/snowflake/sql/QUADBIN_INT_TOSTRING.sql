----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_INT_TOSTRING
(quadbin INT)
RETURNS STRING
AS $$
    TO_VARCHAR(quadbin, 'XXXXXXXXXXXXXXXX')
$$;