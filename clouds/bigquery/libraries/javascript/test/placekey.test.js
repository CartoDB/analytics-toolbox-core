const lib = require('../build/index');

test('placekey library defined', () => {
    expect(lib.placekey.placekeyIsValid).toBeDefined();
    expect(lib.placekey.h3ToPlacekey).toBeDefined();
    expect(lib.placekey.placekeyToH3).toBeDefined();
});