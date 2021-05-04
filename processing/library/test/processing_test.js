const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../processing_library.js')+'');

describe('processing unit tests', () => {

    it ('Version', async () => {
        assert.equal(processingVersion(), '1.0.0');
    });
});
