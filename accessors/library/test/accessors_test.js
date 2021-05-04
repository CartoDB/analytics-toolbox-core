const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../accessors_library.js')+'');

describe('accessors unit tests', () => {

    it ('Version', async () => {
        assert.equal(accessorsVersion(), '1.0.0');
    });
});
