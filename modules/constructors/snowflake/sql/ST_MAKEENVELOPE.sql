----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@constructors.ST_MAKEENVELOPE
(xmin DOUBLE, ymin DOUBLE, xmax DOUBLE, ymax DOUBLE)
RETURNS GEOGRAPHY
AS $$
    ST_MAKEPOLYGON(TO_GEOGRAPHY(CONCAT('LINESTRING(', xmin, ' ', ymin, ',', xmin, ' ', ymax, ',', xmax, ' ', ymax, ',', xmax, ' ', ymin, ',', xmin, ' ', ymin, ')')))
$$;