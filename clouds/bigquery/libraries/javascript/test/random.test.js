const lib = require('../build/index');

test('random library defined', () => {
    expect(lib.random.bbox).toBeDefined();
});