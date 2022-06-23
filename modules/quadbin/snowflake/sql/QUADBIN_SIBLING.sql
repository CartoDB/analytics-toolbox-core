----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION QUADBIN_SIBLING
(quadbin INT, direction STRING)
RETURNS INT
AS $$
    CASE
        WHEN direction = 'left' THEN
            _QUADBIN_SIBLING(quadbin, -1, 0)
        WHEN direction = 'right' THEN
            _QUADBIN_SIBLING(quadbin, 1, 0)
        WHEN direction = 'up' THEN
            _QUADBIN_SIBLING(quadbin, 0, -1)
        WHEN direction = 'down' THEN
            _QUADBIN_SIBLING(quadbin, 0, 1)
        ELSE 
            NULL
    END
$$;