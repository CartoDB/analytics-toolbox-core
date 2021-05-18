----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@constructors.VERSION
()
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    return constructorsLib.version;
$$;