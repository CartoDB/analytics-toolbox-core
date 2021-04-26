const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../clustering_library.js')+'');

describe('CLUSTERING unit tests', () => {

    it ('Version', async () => {
        assert.equal(clusteringVersion(), '1.0.0');
    });
});
