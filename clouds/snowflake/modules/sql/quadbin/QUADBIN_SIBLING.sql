----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

-- FIXME: slow

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_SIBLING
(quadbin BIGINT, direction STRING)
RETURNS INT
IMMUTABLE
AS $$
    CASE direction
        WHEN 'left' THEN
            @@SF_SCHEMA@@._QUADBIN_SIBLING(quadbin, -1, 0)
        WHEN 'right' THEN
            @@SF_SCHEMA@@._QUADBIN_SIBLING(quadbin, 1, 0)
        WHEN 'up' THEN
            @@SF_SCHEMA@@._QUADBIN_SIBLING(quadbin, 0, -1)
        WHEN 'down' THEN
            @@SF_SCHEMA@@._QUADBIN_SIBLING(quadbin, 0, 1)
        ELSE
            NULL
    END
$$;
