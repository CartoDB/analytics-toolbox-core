----------------------------
-- Copyright (C) 2021-2024 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_CENTER
(h3_hex STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    IFF(@@SF_SCHEMA@@.H3_ISVALID(h3_hex), H3_CELL_TO_POINT(h3_hex), NULL)
$$;
