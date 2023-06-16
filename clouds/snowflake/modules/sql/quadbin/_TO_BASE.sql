----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

-- change a float or numeri to other base
CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._TO_BASE
(NUM FLOAT, RADIX FLOAT)
RETURNS FLOAT
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    return parseFloat((NUM.toString(RADIX)));
$$;
