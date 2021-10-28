----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    return '1.0.0'
$$;