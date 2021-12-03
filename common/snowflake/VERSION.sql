----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_VERSION_FUNCTION@@
()
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    return '@@SF_PACKAGE_VERSION@@';
$$;