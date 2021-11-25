----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION __QUADINT_TOCHILDREN
(quadint STRING, resolution DOUBLE)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!QUADINT || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    @@SF_LIBRARY_CONTENT@@

    const quadints = quadkeyLib.toChildren(QUADINT, RESOLUTION);
    return quadints.map(String);
$$;

CREATE OR REPLACE SECURE FUNCTION QUADINT_TOCHILDREN
(quadint BIGINT, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    __QUADINT_TOCHILDREN(CAST(QUADINT AS STRING), CAST(RESOLUTION AS DOUBLE))
$$;