----------------------------
-- Copyright (C) 2022-2023 CARTO
----------------------------

-- Convert a base 10 number in another base
-- useful to create quadkey that is a 4 base
-- representation of it's base 10 number.
CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._TO_BASE
(NUM FLOAT, RADIX FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    return parseFloat((NUM.toString(RADIX)));
$$;
