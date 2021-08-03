const geohashLib = require('../../dist/index');
const version = require('../../package.json').version;

test('geohash library defined', () => {
    expect(geohashLib.version).toBe(version);
});