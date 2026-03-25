----------------------------
-- Copyright (C) 2026 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@DB_SCHEMA@@.QUADBIN_FROMGEOGPOINT
(point GEOMETRY(4326), resolution INT)
RETURNS BIGINT
RETURN
@@DB_SCHEMA@@.QUADBIN_FROMLONGLAT(ST_X(point), ST_Y(point), resolution);
