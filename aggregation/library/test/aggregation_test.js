const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../aggregation_library.js')+'');

describe('AGGREGATION unit tests', () => {

    it ('Version', async () => {
        assert.equal(aggregationVersion(), '1.0.0');
    });
});
