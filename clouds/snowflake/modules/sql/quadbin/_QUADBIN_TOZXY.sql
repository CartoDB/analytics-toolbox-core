----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_TOZXY
(index STRING)
RETURNS OBJECT
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_QUADBIN@@

    return quadbinLib.quadbinToTile(INDEX);
$$;
