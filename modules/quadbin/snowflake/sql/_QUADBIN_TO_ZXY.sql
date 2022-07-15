----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_TOZXY
(index STRING)
RETURNS OBJECT
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_CONTENT@@

    return quadbinLib.quadbinToTile(INDEX);
$$;