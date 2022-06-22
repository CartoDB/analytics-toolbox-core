// Quadbin encoding/decoding in JavaScript
// Not used in the Analytics Toolbox.

function tileToQuadbin (tile) {
    if (tile.z < 0 || tile.z > 26) {
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

    let quadbin = 0x4000000000000000n
        | (1n << 59n) // | (mode << 59) | (mode_dep << 57)
        | (z << 52n)
        | ((x | (y << 1n)) >> 12n)
        | (0xFFFFFFFFFFFFFn >> (z * 2n));
    return quadbin.toString(16);
}

function quadbinToTile (index) {
    const B = [
        0x5555555555555555n, 0x3333333333333333n, 0x0F0F0F0F0F0F0F0Fn,
        0x00FF00FF00FF00FFn, 0x0000FFFF0000FFFFn, 0x00000000FFFFFFFFn];
    const S = [0n, 1n, 2n, 4n, 8n, 16n];
    const quadbin = BigInt('0x' + index);
    const mode = (quadbin >> 59n) & 7n;
    const modeDep = (quadbin >> 57n) & 3n;
    const z = (quadbin >> 52n) & 0x1Fn;
    const q = (quadbin & 0xFFFFFFFFFFFFFn) << 12n;
    let x = q;
    let y = q >> 1n;

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

test('tileToQuadbin should work', async () => {
    expect(quadbinToTile('48a2d06affffffff')).toEqual({ z: 10, x: 200, y: 391 });
});

test('quadbinToTile should work', async () => {
    expect(tileToQuadbin({ z: 10, x: 200, y: 391 })).toEqual('48a2d06affffffff');
});