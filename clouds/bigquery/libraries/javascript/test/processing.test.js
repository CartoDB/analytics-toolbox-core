const processingLib = require('../build/processing');

test('processing library defined', () => {
    expect(processingLib.featureCollection).toBeDefined();
    expect(processingLib.feature).toBeDefined();
    expect(processingLib.voronoi).toBeDefined();
    expect(processingLib.polygonToLine).toBeDefined();
});