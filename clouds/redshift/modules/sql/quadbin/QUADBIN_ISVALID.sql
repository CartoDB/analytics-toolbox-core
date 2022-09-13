----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_ISVALID
(quadbin BIGINT)
RETURNS BOOLEAN
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import is_valid_cell

    if quadbin is None:
        return False

    return is_valid_cell(quadbin)
$$ LANGUAGE PLPYTHONU;
