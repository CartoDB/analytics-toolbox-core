----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@PG_SCHEMA@@.QUADBIN_BBOX(
    quadbin BIGINT
)
RETURNS DOUBLE PRECISION[]
AS
$BODY$
    SELECT CASE
        WHEN quadbin IS NULL THEN
            NULL
        ELSE (
            WITH
            __zxy AS (
                SELECT @@PG_SCHEMA@@.QUADBIN_TOZXY(quadbin) AS tile
            )
            SELECT ARRAY[
                180 * (2.0 * (tile->>'x')::DOUBLE PRECISION / (1 << (tile->>'z')::INT)::DOUBLE PRECISION - 1.0),
                360 * (ATAN(EXP(-(2.0 * ((tile->>'y')::DOUBLE PRECISION + 1.0) / (1 << (tile->>'z')::INT)::DOUBLE PRECISION - 1.0) * PI())) / PI() - 0.25),
                180 * (2.0 * ((tile->>'x')::DOUBLE PRECISION + 1.0) / (1 << (tile->>'z')::INT)::DOUBLE PRECISION - 1.0),
                360 * (ATAN(EXP(-(2.0 * (tile->>'y')::DOUBLE PRECISION / (1 << (tile->>'z')::INT)::DOUBLE PRECISION - 1) * PI())) / PI() - 0.25)
            ]
            FROM __zxy
        )
    END
$BODY$
LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
