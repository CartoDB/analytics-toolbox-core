----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _H3_ASPLACEKEY
(h3Index STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
AS $$
    @@SF_LIBRARY_CONTENT@@
    
    return placekeyLib.h3ToPlacekey(H3INDEX);
$$;

CREATE OR REPLACE SECURE FUNCTION H3_ASPLACEKEY
(h3Index STRING)
RETURNS STRING
AS $$
    IFF(ISVALID(H3INDEX),
      _H3_ASPLACEKEY(H3INDEX),
      null)
$$;