const randomLib = require('../build/random');

test('random library defined', () => {
    expect(randomLib.generateRandomPointsInPolygon).toBeDefined();
});