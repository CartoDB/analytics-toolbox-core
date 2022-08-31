const coreLib = require('../build/index');

test('accessors library defined', () => {
    expect(coreLib.accessors.featureCollection).toBeDefined();
    expect(coreLib.accessors.feature).toBeDefined();
    expect(coreLib.accessors.envelope).toBeDefined();
});