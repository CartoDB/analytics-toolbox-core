----------------------------
-- Copyright (C) 2023 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_DISTANCE
(origin STRING, destination STRING)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    if (!ORIGIN || !DESTINATION) {
        return null;
    }

    @@SF_LIBRARY_QUADBIN@@

    origin_coords = quadbinLib.quadbinToTile(ORIGIN);
    destination_coords = quadbinLib.quadbinToTile(DESTINATION);

    if (origin_coords.z != destination_coords.z) {
        return null;
    }
    return Math.max(Math.abs(origin_coords.x - destination_coords.x), Math.abs(origin_coords.y - destination_coords.y));
$$;


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_DISTANCE
(origin BIGINT, destination BIGINT)
RETURNS BIGINT
IMMUTABLE
AS $$
    CAST(@@SF_SCHEMA@@._QUADBIN_DISTANCE(TO_VARCHAR(ORIGIN, 'xxxxxxxxxxxxxxxx'), TO_VARCHAR(DESTINATION, 'xxxxxxxxxxxxxxxx')) AS BIGINT)
$$;
