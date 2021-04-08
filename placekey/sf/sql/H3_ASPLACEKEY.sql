-----------------------------------------------------------------------
--
-- Copyright (C) 2021 CARTO
--
-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@._H3_ASPLACEKEY(h3Index STRING)
    RETURNS STRING
    LANGUAGE JAVASCRIPT
AS $$
    @@LIBRARY_FILE_CONTENT@@
    
    return h3ToPlacekey(H3INDEX);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@.H3_ASPLACEKEY(h3Index STRING)
    RETURNS STRING
AS $$
    IFF(@@SF_DATABASEID@@.@@SF_SCHEMA_H3@@.ISVALID(H3INDEX),
      @@SF_DATABASEID@@.@@SF_SCHEMA_PLACEKEY@@._H3_ASPLACEKEY(H3INDEX),
      null)
$$;