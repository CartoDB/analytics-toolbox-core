--------------------------------
-- Copyright (C) 2023-2024 CARTO
--------------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.H3_CENTER
(index STRING)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    IFF(@@SF_SCHEMA@@.H3_ISVALID(INDEX), H3_CELL_TO_POINT(INDEX), NULL)
$$;
