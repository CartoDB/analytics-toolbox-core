const placekeyLib = require('../../dist/index');
const version = require('../../package.json').version;

test('placekey library defined', () => {
    expect(placekeyLib.placekeyIsValid).toBeDefined();
    expect(placekeyLib.h3ToPlacekey).toBeDefined();
    expect(placekeyLib.placekeyToH3).toBeDefined();
    expect(placekeyLib.version).toBe(version);
});