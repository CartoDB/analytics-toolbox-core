----------------------------
-- Copyright (C) 2023 CARTO
----------------------------


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_BOUNDARY
(quadbin BIGINT)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    WITH
    __bbox AS (
        SELECT
            @@SF_SCHEMA@@.QUADBIN_BBOX(quadbin) AS corners
    )
    SELECT
        ST_MAKEPOLYGON(
            TRY_TO_GEOGRAPHY(
                'LINESTRING(' || 
                corners[2]::DECIMAL(18,15) ||  ' ' ||  corners[3]::DECIMAL(18,15) ||  ',' || 
                corners[2]::DECIMAL(18,15) ||  ' ' ||  corners[1]::DECIMAL(18,15) ||  ',' || 
                corners[0]::DECIMAL(18,15) ||  ' ' ||  corners[1]::DECIMAL(18,15) ||  ',' || 
                corners[0]::DECIMAL(18,15) ||  ' ' ||  corners[3]::DECIMAL(18,15) ||  ',' || 
                corners[2]::DECIMAL(18,15) ||  ' ' ||  corners[3]::DECIMAL(18,15) || ')'
            )
        )
    FROM __bbox
$$;
