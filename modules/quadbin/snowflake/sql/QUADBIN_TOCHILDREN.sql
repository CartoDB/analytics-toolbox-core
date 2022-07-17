----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_TOCHILDREN
(index STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$
    @@SF_LIBRARY_CONTENT@@

    const res = Number(RESOLUTION);
    const tile = quadbinLib.quadbinToTile(INDEX);
    const xmin = tile.x << (res - tile.z);
    const xmax = ((tile.x + 1) << (res - tile.z)) - 1;
    const ymin = tile.y << (res - tile.z);
    const ymax = ((tile.y + 1) << (res - tile.z)) - 1;

    let children = '[';

    for (let dx=xmin; dx<=xmax; dx+=1) {
        for (let dy=ymin; dy<=ymax; dy+=1) {
            const child = quadbinLib.tileToQuadbin(
                {z: res, x: dx, y: dy}
            );
            children += String(BigInt(`0x${child}`)) + ',';
        }
    }

    return children.slice(0, -1) + ']';
$$;


CREATE OR REPLACE FUNCTION QUADBIN_TOCHILDREN
(quadbin BIGINT, resolution INT)
RETURNS ARRAY
IMMUTABLE
AS $$
    TO_ARRAY(PARSE_JSON(_QUADBIN_TOCHILDREN(TO_VARCHAR(QUADBIN, 'xxxxxxxxxxxxxxxx'), RESOLUTION)))
$$;
