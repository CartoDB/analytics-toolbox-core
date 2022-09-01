const coreLib = require('../build/index');

test('processing library defined', () => {
    expect(coreLib.processing.featureCollection).toBeDefined();
    expect(coreLib.processing.feature).toBeDefined();
    expect(coreLib.processing.voronoi).toBeDefined();
    expect(coreLib.processing.polygonToLine).toBeDefined();
});