const clusteringLib = require('../build/clustering');

test('clustering library defined', () => {
    expect(clusteringLib.featureCollection).toBeDefined();
    expect(clusteringLib.feature).toBeDefined();
    expect(clusteringLib.clustersKmeans).toBeDefined();
    expect(clusteringLib.prioritizeDistinctSort).toBeDefined();
});