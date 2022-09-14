----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.ST_MAKEENVELOPE
(xmin DOUBLE, ymin DOUBLE, xmax DOUBLE, ymax DOUBLE)
RETURNS GEOGRAPHY
IMMUTABLE
AS $$
    TO_GEOGRAPHY(CONCAT('POLYGON((', xmin, ' ', ymin, ',', xmin, ' ', ymax, ',', xmax, ' ', ymax, ',', xmax, ' ', ymin, ',', xmin, ' ', ymin, '))'))
$$;