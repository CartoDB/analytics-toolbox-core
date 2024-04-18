---------------------------------
-- Copyright (C) 2022-2024 CARTO
---------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_STRING_TOINT
(
    index STRING
)
RETURNS INT
AS $$
  H3_STRING_TO_INT(INDEX)
$$;
