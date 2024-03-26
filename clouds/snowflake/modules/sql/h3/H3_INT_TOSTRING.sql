---------------------------------
-- Copyright (C) 2021-2024 CARTO
---------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_INT_TOSTRING
(
    h3_int INT
)
RETURNS STRING
AS $$
  H3_INT_TO_STRING(h3_int)
$$;
