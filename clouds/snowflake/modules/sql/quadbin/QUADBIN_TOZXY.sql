--------------------------------
-- Copyright (C) 2022-2023 CARTO
--------------------------------


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOZXY
(quadbin BIGINT)
RETURNS OBJECT
IMMUTABLE
AS $$
    IFF(quadbin IS NULL,
        NULL,
        @@SF_SCHEMA@@._QUADBIN_TOZXY(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx'))
    )
$$;
