const lib = require('../build/index');

test('processing library defined', () => {
    expect(lib.processing.featureCollection).toBeDefined();
    expect(lib.processing.feature).toBeDefined();
    expect(lib.processing.voronoi).toBeDefined();
    expect(lib.processing.polygonToLine).toBeDefined();
});