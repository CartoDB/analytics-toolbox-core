---------------------------------
-- Copyright (C) 2022-2024 CARTO
---------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_INT_TOSTRING
(
    h3int INT
)
RETURNS STRING
AS $$
  H3_INT_TO_STRING(h3int)
$$;
