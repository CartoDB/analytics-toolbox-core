----------------------------
-- Copyright (C) 2021 CARTO
----------------------------

CREATE OR REPLACE SECURE FUNCTION @@SF_PREFIX@@s2.ST_ASID
(point GEOGRAPHY, resolution INT)
RETURNS BIGINT
AS $$
    @@SF_PREFIX@@s2.LONGLAT_ASID(ST_X(POINT), ST_Y(POINT), RESOLUTION)
$$;
