----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_SIBLING
(quadbin BIGINT, direction VARCHAR)
RETURNS BIGINT
IMMUTABLE
AS $$
    from @@RS_LIBRARY@@.quadbin import cell_sibling

    if quadbin is None or direction is None:
        return None

    return cell_sibling(quadbin, direction)
$$ LANGUAGE PLPYTHONU;
