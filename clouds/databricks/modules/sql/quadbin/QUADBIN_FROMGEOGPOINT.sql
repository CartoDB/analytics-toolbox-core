----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT
(longitude DOUBLE, latitude DOUBLE, resolution INT)
RETURNS BIGINT
RETURN
    @@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(longitude, latitude, resolution);
