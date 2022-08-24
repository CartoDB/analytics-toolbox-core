const processingLib = require('../build/processing');

test('processing library defined', () => {
    expect(processingLib.voronoi).toBeDefined();
    expect(processingLib.polygonToLine).toBeDefined();
});