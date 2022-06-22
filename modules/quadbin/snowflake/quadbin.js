function tileToQuadbin (tile) {
    if (tile.z < 0 || tile.z > 29) {
        throw new Error('Wrong zoom');
    }
    const B = [
        0x5555555555555555n, 0x3333333333333333n, 0x0F0F0F0F0F0F0F0Fn,
        0x00FF00FF00FF00FFn, 0x0000FFFF0000FFFFn];
    const S = [1n, 2n, 4n, 8n, 16n];
    let z = BigInt(tile.z);
    let x = BigInt(tile.x) << (32n - z);
    let y = BigInt(tile.y) << (32n - z);

    x = (x | (x << S[4])) & B[4];
    y = (y | (y << S[4])) & B[4];

    x = (x | (x << S[3])) & B[3];
    y = (y | (y << S[3])) & B[3];

    x = (x | (x << S[2])) & B[2];
    y = (y | (y << S[2])) & B[2];

    x = (x | (x << S[1])) & B[1];
    y = (y | (y << S[1])) & B[1];

    x = (x | (x << S[0])) & B[0];
    y = (y | (y << S[0])) & B[0];

    let quadbin = (z << 58n) | ((x | (y << 1n)) >> 6n);
    return quadbin.toString(16);
}

function quadbinToTile (index) {
    const B = [
        0x5555555555555555n, 0x3333333333333333n, 0x0F0F0F0F0F0F0F0Fn,
        0x00FF00FF00FF00FFn, 0x0000FFFF0000FFFFn, 0x00000000FFFFFFFFn]
    const S = [0n, 1n, 2n, 4n, 8n, 16n]
    const quadbin = BigInt('0x' + index)
    const z = quadbin >> 58n
    const xy = (quadbin & 0x3FFFFFFFFFFFFFFn) << 6n
    let x = xy;
    let y = xy >> 1n;

    x = (x | (x >> S[0])) & B[0];
    y = (y | (y >> S[0])) & B[0];

    x = (x | (x >> S[1])) & B[1];
    y = (y | (y >> S[1])) & B[1];

    x = (x | (x >> S[2])) & B[2];
    y = (y | (y >> S[2])) & B[2];

    x = (x | (x >> S[3])) & B[3];
    y = (y | (y >> S[3])) & B[3];

    x = (x | (x >> S[4])) & B[4];
    y = (y | (y >> S[4])) & B[4];

    x = (x | (x >> S[5])) & B[5];
    y = (y | (y >> S[5])) & B[5];

    x = x >> (32n - z);
    y = y >> (32n - z);

    return { z: Number(z), x: Number(x), y: Number(y) };
}

console.log(quadbinToTile('28b41a8000000000'))
console.log(tileToQuadbin({ z: 10, x: 200, y: 391 }))