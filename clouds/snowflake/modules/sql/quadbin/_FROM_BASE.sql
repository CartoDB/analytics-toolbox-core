----------------------------
-- Copyright (C) 2022-2023 CARTO
----------------------------

-- do interpreteation of a number as in another base and
-- return it in base 10
-- useful to convert a quadkey that is a 4 base
-- number and transform it is base 10 number.
CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._FROM_BASE
(NUM FLOAT, RADIX FLOAT)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    return parseInt(NUM.toString(), RADIX).toString();
$$;
