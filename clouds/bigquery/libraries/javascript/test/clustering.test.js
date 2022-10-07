const lib = require('../build/index');

test('clustering library defined', () => {
    expect(lib.clustering.featureCollection).toBeDefined();
    expect(lib.clustering.feature).toBeDefined();
    expect(lib.clustering.clustersKmeans).toBeDefined();
});