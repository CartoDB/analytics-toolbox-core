const lib = require('../build/index');

test('random library defined', () => {
    expect(lib.random.generateRandomPointsInPolygon).toBeDefined();
});