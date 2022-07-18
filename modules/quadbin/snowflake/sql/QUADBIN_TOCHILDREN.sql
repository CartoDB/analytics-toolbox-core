----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

-- The function returns a STRING for two main issues related with Snowflake limitations
-- 1. Snowflake has a native support of BigInt numbers, however, if the UDF
-- returns this data type the next Snowflake internal error is raised:
-- SQL execution internal error: Processing aborted due to error 300010:3321206824
-- 2. If the UDF returns the hex codification of the quadbin to be parsed in a SQL
-- higher level by using the _QUADBIN_STRING_TOINT UDF a non-correlated query can be produced.

CREATE OR REPLACE FUNCTION _QUADBIN_TOCHILDREN
(index STRING, resolution DOUBLE)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    @@SF_LIBRARY_CONTENT@@
    
    if (INDEX == null || RESOLUTION == null) {
        throw new Error('NULL argument passed to UDF');
    }

    if (RESOLUTION < 0 || RESOLUTION > 26) {
        throw new Error('Invalid resolution, it must be between 0 and 26.');
    }

    const tile = quadbinLib.quadbinToTile(INDEX);

    if (RESOLUTION < tile.z) {
        throw new Error('Invalid resolution, it should be higher than the quadbin level.');
    }

    const res = Number(RESOLUTION);
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
