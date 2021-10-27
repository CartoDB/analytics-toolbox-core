----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _TOCHILDREN
(quadint STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@

    if (!QUADINT || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }
    const quadints = quadkeyLib.toChildren(QUADINT, RESOLUTION);
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION TOCHILDREN
(quadint BIGINT, resolution INT)
RETURNS ARRAY
AS $$
    _TOCHILDREN(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE))
$$;