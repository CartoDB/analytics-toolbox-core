const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../transform_library.js')+'');

describe('TRANSFORM unit tests', () => {

    it ('Version', async () => {
        assert.equal(transformVersion(), '1.0.0');
    });

});
