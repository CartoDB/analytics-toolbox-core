----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_BBOX
(index STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_QUADBIN@@

    return quadbinLib.getQuadbinBoundingBox(INDEX);
$$;

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_BBOX
(quadbin BIGINT)
RETURNS ARRAY
IMMUTABLE
AS $$
    WITH array_polygon AS (
        SELECT @@SF_SCHEMA@@._QUADBIN_BBOX(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx')) p
    )
    SELECT
        CASE
            WHEN ARRAY_SIZE(p) = 0 THEN NULL
            ELSE p
        END
    FROM array_polygon
$$;
