----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_TOZXY_AUX
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


CREATE OR REPLACE SECURE FUNCTION _QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS OBJECT
IMMUTABLE
AS $$
    _QUADBIN_TOZXY_AUX(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx'))
$$;
