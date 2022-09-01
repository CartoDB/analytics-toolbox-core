const coreLib = require('../build/index');

test('placekey library defined', () => {
    expect(coreLib.placekey.placekeyIsValid).toBeDefined();
    expect(coreLib.placekey.h3ToPlacekey).toBeDefined();
    expect(coreLib.placekey.placekeyToH3).toBeDefined();
});