----------------------------
-- Copyright (C) 2025 CARTO
----------------------------

-- QUADBIN_POLYFILL
-- Returns an array of Quadbin indices that cover the given geometry at a specified resolution.
-- This is useful for spatial indexing and analysis of geographic data.
--
-- Signature: QUADBIN_POLYFILL(geom GEOMETRY, resolution INTEGER) -> SUPER (array of BIGINT)
--
-- Parameters:
--   geom: Input geometry to cover with quadbins
--   resolution: Quadbin resolution level (0-26)
--
-- Returns: Array of Quadbin indices covering the geometry
--
-- Examples:
--   SELECT QUADBIN_POLYFILL(ST_POINT(-3.70325, 40.4165), 4);
--   -- Returns: [5209574053332910079]

-- Internal external function (VARCHAR in/out)
CREATE OR REPLACE EXTERNAL FUNCTION @@SCHEMA@@.__QUADBIN_POLYFILL_EXFUNC(
    geom VARCHAR(MAX),
    resolution INTEGER
)
RETURNS VARCHAR(MAX)
STABLE
LAMBDA '@@LAMBDA_ARN@@'
IAM_ROLE '@@IAM_ROLE_ARN@@';

-- Public wrapper function (GEOMETRY in, SUPER out)
CREATE OR REPLACE FUNCTION @@SCHEMA@@.QUADBIN_POLYFILL(
    geom GEOMETRY,
    resolution INTEGER
)
RETURNS SUPER
STABLE
AS $$
    SELECT CASE ST_SRID($1)
        WHEN 0 THEN JSON_PARSE(@@SCHEMA@@.__QUADBIN_POLYFILL_EXFUNC(ST_ASGEOJSON(ST_SETSRID($1, 4326))::VARCHAR(MAX), $2))
        ELSE JSON_PARSE(@@SCHEMA@@.__QUADBIN_POLYFILL_EXFUNC(ST_ASGEOJSON(ST_TRANSFORM($1, 4326))::VARCHAR(MAX), $2))
    END
$$ LANGUAGE sql;
