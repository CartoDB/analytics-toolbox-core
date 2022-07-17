----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

-- The function returns a STRING for two main issues related with Snowflake limitations
-- 1. Snowflake has a native support of BigInt numbers, however, if the UDF
-- returns this data type the next Snowflake internal error is raised:
-- SQL execution internal error: Processing aborted due to error 300010:3321206824
-- 2. If the UDF returns the hex codification of the quadbin to be parsed in a SQL
-- higher level by using the _QUADBIN_STRING_TOINT UDF a non-correlated query can be produced.


CREATE OR REPLACE FUNCTION _QUADBIN_KRING
(index STRING, size DOUBLE, distanceFlag BOOLEAN)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    @@SF_LIBRARY_CONTENT@@

    const offset = Number(SIZE);
    const inputTile = quadbinLib.quadbinToTile(INDEX);
    let krings = '[';
    for (let dx=-offset; dx<=offset; dx+=1) {
        for (let dy=-offset; dy<=offset; dy+=1) {
            const tile = {
                z: inputTile.z,
                x: inputTile.x + dx, 
                y: inputTile.y + dy  
            };
            const quadbin = quadbinLib.tileToQuadbin(tile);
            const quadbinIndex = String(BigInt(`0x${quadbin}`)) ;

            if (DISTANCEFLAG) {
                krings += '{index:' + quadbinIndex + ',distance:' +  Math.max(Math.abs(dx), Math.abs(dy)) + '},';
            } else {
                krings += quadbinIndex + ',';
            }
        }
    }

    return krings.slice(0, -1) + ']';
$$;
