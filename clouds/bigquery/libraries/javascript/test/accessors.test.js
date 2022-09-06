const lib = require('../build/index');

test('accessors library defined', () => {
    expect(lib.accessors.featureCollection).toBeDefined();
    expect(lib.accessors.feature).toBeDefined();
    expect(lib.accessors.envelope).toBeDefined();
});