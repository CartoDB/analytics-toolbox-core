----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@RS_SCHEMA@@.QUADBIN_DISTANCE
(origin BIGINT, destination BIGINT)
RETURNS BIGINT
STABLE
AS $$
    SELECT CASE WHEN $1 IS NULL OR $2 IS NULL THEN
        NULL 
    ELSE
        CASE WHEN @@RS_SCHEMA@@.QUADBIN_RESOLUTION($1) != @@RS_SCHEMA@@.QUADBIN_RESOLUTION($2) THEN
            NULL 
        ELSE
            GREATEST(
                ABS(
                    (@@RS_SCHEMA@@.__QUADBIN_TOZXY_X($2) >> (32 - CAST(@@RS_SCHEMA@@.QUADBIN_RESOLUTION($2) AS INT))) -
                    (@@RS_SCHEMA@@.__QUADBIN_TOZXY_X($1) >> (32 - CAST(@@RS_SCHEMA@@.QUADBIN_RESOLUTION($1) AS INT)))
                ),
                ABS(
                    (@@RS_SCHEMA@@.__QUADBIN_TOZXY_Y($2) >> (32 - CAST(@@RS_SCHEMA@@.QUADBIN_RESOLUTION($2) AS INT))) -
                    (@@RS_SCHEMA@@.__QUADBIN_TOZXY_Y($1) >> (32 - CAST(@@RS_SCHEMA@@.QUADBIN_RESOLUTION($1) AS INT)))
                )
            )
        END
    END
$$ LANGUAGE sql;
