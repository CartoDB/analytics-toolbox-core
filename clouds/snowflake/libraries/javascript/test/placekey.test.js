const placekeyLib = require('../build/placekey');

test('placekey library defined', () => {
    expect(placekeyLib.placekeyIsValid).toBeDefined();
    expect(placekeyLib.h3ToPlacekey).toBeDefined();
    expect(placekeyLib.placekeyToH3).toBeDefined();
});