----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_TOZXY
(BIGINT)
-- (quadbin)
RETURNS SUPER
STABLE
AS $$
    SELECT json_parse('{' ||
        '"z": ' || @@RS_SCHEMA@@.QUADBIN_RESOLUTION($1) || ',' ||
        '"x": ' || (@@RS_SCHEMA@@.__QUADBIN_TOZXY_X($1) >> (32 - CAST(@@RS_SCHEMA@@.QUADBIN_RESOLUTION($1) AS INT))) || ',' ||
        '"y": ' || (@@RS_SCHEMA@@.__QUADBIN_TOZXY_Y($1) >> (32 - CAST(@@RS_SCHEMA@@.QUADBIN_RESOLUTION($1) AS INT))) || '}'
        )
$$ LANGUAGE sql;
