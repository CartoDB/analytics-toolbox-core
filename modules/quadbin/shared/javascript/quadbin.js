// from: https://github.com/visgl/deck.gl/blob/master/modules/carto/src/layers/quadbin-utils.ts
import {worldToLngLat} from '@math.gl/web-mercator';
import tilecover from '@mapbox/tile-cover';

const TILE_SIZE = 512;

const B = [
  0x5555555555555555n,
  0x3333333333333333n,
  0x0f0f0f0f0f0f0f0fn,
  0x00ff00ff00ff00ffn,
  0x0000ffff0000ffffn,
  0x00000000ffffffffn
];
const S = [0n, 1n, 2n, 4n, 8n, 16n];

function indexToBigInt(index) {
  return BigInt(`0x${index}`);
}

function bigIntToIndex(quadbin) {
  return quadbin.toString(16);
}

export function tileToQuadbin(tile) {
  if (tile.z < 0 || tile.z > 26) {
    throw new Error('Wrong zoom');
  }
  const z = BigInt(tile.z);
  let x = BigInt(tile.x) << (32n - z);
  let y = BigInt(tile.y) << (32n - z);

  for (let i = 0; i < 5; i++) {
    const s = S[5 - i];
    const b = B[4 - i];
    x = (x | (x << s)) & b;
    y = (y | (y << s)) & b;
  }

  const quadbin =
    0x4000000000000000n |
    (1n << 59n) | // | (mode << 59) | (mode_dep << 57)
    (z << 52n) |
    ((x | (y << 1n)) >> 12n) |
    (0xfffffffffffffn >> (z * 2n));
  return bigIntToIndex(quadbin);
}

export function quadbinToTile(index) {
  const quadbin = indexToBigInt(index);
  const mode = (quadbin >> 59n) & 7n;
  const modeDep = (quadbin >> 57n) & 3n;
  const z = (quadbin >> 52n) & 0x1fn;
  const q = (quadbin & 0xfffffffffffffn) << 12n;

  if (mode !== 1n && modeDep !== 0n) {
    throw new Error('Wrong mode');
  }

  let x = q;
  let y = q >> 1n;

  for (let i = 0; i < 6; i++) {
    const s = S[i];
    const b = B[i];
    x = (x | (x >> s)) & b;
    y = (y | (y >> s)) & b;
  }

  x = x >> (32n - z);
  y = y >> (32n - z);

  return {z: Number(z), x: Number(x), y: Number(y)};
}

export function quadbinZoom(index) {
  const quadbin = indexToBigInt(index);
  return (quadbin >> 52n) & 0x1fn;
}

export function quadbinParent(index) {
  const quadbin = indexToBigInt(index);
  const zparent = quadbinZoom(index) - 1n;
  const parent =
    (quadbin & ~(0x1fn << 52n)) | (zparent << 52n) | (0xfffffffffffffn >> (zparent * 2n));
  return bigIntToIndex(parent);
}

export function quadbinToWorldBounds(quadbin) {
  const {x, y, z} = quadbinToTile(quadbin);
  const mask = 1 << z;
  const scale = mask / TILE_SIZE;
  return [
    [x / scale, TILE_SIZE - y / scale],
    [(x + 1.0) / scale, TILE_SIZE - (y + 1.0) / scale]
  ];
}

export function getQuadbinBoundingBox(quadbin) {
  const [topLeft, bottomRight] = quadbinToWorldBounds(quadbin);
  const [w, n] = worldToLngLat(topLeft);
  const [e, s] = worldToLngLat(bottomRight);
  return [w, s, e, n];
}

export function getQuadbinPolygon(quadbin) {
  const [topLeft, bottomRight] = quadbinToWorldBounds(quadbin);
  const [w, n] = worldToLngLat(topLeft);
  const [e, s] = worldToLngLat(bottomRight);
  return [e, n, e, s, w, s, w, n, e, n];
}

/**
 * get an array of quadints containing a geography for given zooms
 * @param  {object} poly    geography we want to extract the quadints from
 * @param  {struct} limits  struct containing the range of zooms
 * @return {array}          array of quadbins containing a geography
 */
export function geojsonToQuadbins (poly, limits) {
  return tilecover.tiles(poly, limits).map(tile => 
    String(indexToBigInt(tileToQuadbin({z: tile[2], x: tile[0], y: tile[1]}))));
}
