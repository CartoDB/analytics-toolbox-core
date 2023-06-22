----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

-- change a float or numeri to other base
CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._FROM_BASE
(NUM FLOAT, RADIX FLOAT)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    return parseInt(NUM.toString(), RADIX).toString();
$$;
