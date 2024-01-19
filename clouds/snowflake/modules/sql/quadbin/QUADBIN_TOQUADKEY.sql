--------------------------------
-- Copyright (C) 2022-2023 CARTO
--------------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_TOQUADKEY
(quadbin STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    const q = BigInt(QUADBIN);
    const z = (q >> 52n) & 0x1Fn;
    const xy = (q & 0xFFFFFFFFFFFFFn) >> (52n - z*2n);
    return (z == 0) ? '' : xy.toString(4).padStart(Number(z), '0');
$$;


CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOQUADKEY
(quadbin BIGINT)
RETURNS STRING
IMMUTABLE
AS $$
    IFF(quadbin IS NULL,
        NULL,
        @@SF_SCHEMA@@._QUADBIN_TOQUADKEY(CAST(QUADBIN AS STRING))
    )
$$;
