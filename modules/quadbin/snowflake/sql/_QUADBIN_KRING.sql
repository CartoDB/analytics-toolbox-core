----------------------------
-- Copyright (C) 2022 CARTO
----------------------------

CREATE OR REPLACE FUNCTION _QUADBIN_KRING
(index STRING, size DOUBLE, distanceFlag BOOLEAN)
RETURNS ARRAY
LANGUAGE JAVASCRIPT
IMMUTABLE
AS $$

    @@SF_LIBRARY_CONTENT@@

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
            const quadbinIndex = parseInt(BigInt(`0x${quadbin}`));

            if (DISTANCEFLAG) {
                const kringObject = {
                    index: quadbinIndex,
                    distance: Math.max(Math.abs(dx), Math.abs(dy))
                }
                krings.push(kringObject);
            } else {
                krings.push(quadbinIndex);
            }
        }
    }

    return krings;
$$;
