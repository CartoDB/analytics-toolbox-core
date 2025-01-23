const accessorsLib = require('../build/accessors');

test('accessors library defined', () => {
    expect(accessorsLib.featureCollection).toBeDefined();
    expect(accessorsLib.feature).toBeDefined();
    expect(accessorsLib.envelope).toBeDefined();
});