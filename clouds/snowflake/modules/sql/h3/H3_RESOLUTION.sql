---------------------------------
-- Copyright (C) 2023-2024 CARTO
---------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_RESOLUTION
(
    h3 STRING
)
RETURNS INT
AS $$
    IFF(@@SF_SCHEMA@@.H3_ISVALID(h3), H3_GET_RESOLUTION(h3), NULL)
$$;
