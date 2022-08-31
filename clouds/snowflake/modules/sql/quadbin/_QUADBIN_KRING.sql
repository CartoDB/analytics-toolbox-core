----------------------------
-- Copyright (C) 2022 CARTO
----------------------------


CREATE OR REPLACE FUNCTION @@SF_SCHEMA@@._QUADBIN_KRING
(index STRING, size DOUBLE, distanceFlag BOOLEAN)
RETURNS STRING
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    @@SF_LIBRARY_QUADBIN@@

    const offset = Number(SIZE);
    const inputTile = quadbinLib.quadbinToTile(INDEX);
    const krings = [];
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
                krings.push('{index:' + quadbinIndex + ',distance:' +  Math.max(Math.abs(dx), Math.abs(dy)) + '}');
            } else {
                krings.push(quadbinIndex);
            }
        }
    }

    return '[' + krings.join(',') + ']';
$$;
