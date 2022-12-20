----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_TOCHILDREN
(index STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    @@SF_LIBRARY_QUADBIN@@

    const res = Number(RESOLUTION);

    if (INDEX == null || res == null) {
        throw new Error('NULL argument passed to UDF');
    }

    if (res < 0 || res > 26) {
        throw new Error('Invalid resolution, it must be between 0 and 26.');
    }

    const tile = quadbinLib.quadbinToTile(INDEX);

    if (res < tile.z) {
        throw new Error('Invalid resolution, it should be higher than the quadbin level.');
    }

    const xmin = tile.x << (res - tile.z);
    const xmax = ((tile.x + 1) << (res - tile.z)) - 1;
    const ymin = tile.y << (res - tile.z);
    const ymax = ((tile.y + 1) << (res - tile.z)) - 1;

    const children = [];

    for (let dx=xmin; dx<=xmax; dx+=1) {
        for (let dy=ymin; dy<=ymax; dy+=1) {
            const child = quadbinLib.tileToQuadbin(
                {z: res, x: dx, y: dy}
            );
            children.push(String(BigInt(`0x${child}`)));
        }
    }

    return '[' + children.join(',') + ']';
$$;


CREATE OR REPLACE SECURE FUNCTION @@SF_SCHEMA@@.QUADBIN_TOCHILDREN
(quadbin BIGINT, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    TO_ARRAY(PARSE_JSON(@@SF_SCHEMA@@._QUADBIN_TOCHILDREN(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx'), RESOLUTION)))
$$;
