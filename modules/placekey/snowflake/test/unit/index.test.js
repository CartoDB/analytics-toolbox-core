const lib = require('../../dist/index');
const version = require('../../package.json').version;

test('library defined', () => {
    expect(lib.placekeyIsValid).toBeDefined();
    expect(lib.h3ToPlacekey).toBeDefined();
    expect(lib.placekeyToH3).toBeDefined();
    expect(lib.version).toBe(version);
});
