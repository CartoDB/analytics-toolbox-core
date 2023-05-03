----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.H3_RESOLUTION
(
    h3 STRING
)
RETURNS INT
AS $$
    IFF(@@SF_SCHEMA@@.H3_ISVALID(h3),
        bitshiftright(bitand(@@SF_SCHEMA@@.H3_STRING_TOINT(h3),
            bitshiftleft(15, 52)), 52),
        NULL)
$$;
