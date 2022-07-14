----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION _QUADBIN_BBOX
(index STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_CONTENT@@

    return quadbinLib.getQuadbinPolygon(INDEX);
$$;

CREATE OR REPLACE SECURE FUNCTION QUADBIN_BBOX
(quadbin BIGINT)
RETURNS ARRAY
IMMUTABLE
AS $$
    WITH array_polygon AS (
        SELECT _QUADBIN_BBOX(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx')) p
    )
    SELECT 
        CASE 
            WHEN ARRAY_SIZE(p) = 0 THEN NULL
            ELSE 
            ARRAY_CONSTRUCT(
                GET(p, 4), GET(p, 3), GET(p, 0), GET(p, 1)
            )
        END
    FROM array_polygon
$$;