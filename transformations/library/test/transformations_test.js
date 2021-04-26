const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../transformations_library.js')+'');

describe('TRANSFORMATIONS unit tests', () => {

    it ('Version', async () => {
        assert.equal(transformationsVersion(), '1.0.0');
    });

});
