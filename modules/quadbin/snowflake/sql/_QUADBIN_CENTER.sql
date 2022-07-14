----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_CENTER_AUX
(index STRING)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!INDEX) {
        return [];
    }

    @@SF_LIBRARY_CONTENT@@

    return quadbinLib.quadbinCenter(INDEX);
$$;


CREATE OR REPLACE SECURE FUNCTION _QUADBIN_CENTER
(quadbin BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
--AS $$
--    WITH array_point AS (
--        SELECT _QUADBIN_CENTER_AUX(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx')) p
--    )
--    SELECT 
--        CASE 
--            WHEN ARRAY_SIZE(p) = 0 THEN NULL
--            ELSE 
--            ST_MAKEPOINT(GET(p, 0), GET(p, 1))
--        END
--    FROM array_point
--$$;

AS $$
    ST_CENTROID(_QUADBIN_BOUNDARY(QUADBIN))
$$