----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_VERSION_FUNCTION@@
()
RETURNS STRING
IMMUTABLE
AS $$
    '@@SF_PACKAGE_VERSION@@'
$$;