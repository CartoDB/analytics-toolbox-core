const processingLib = require('../../dist/index');
const version = require('../../package.json').version;

test('processing library defined', () => {
    expect(processingLib.featureCollection).toBeDefined();
    expect(processingLib.feature).toBeDefined();
    expect(processingLib.voronoi).toBeDefined();
    expect(processingLib.polygonToLine).toBeDefined();
    expect(processingLib.version).toBe(version);
});