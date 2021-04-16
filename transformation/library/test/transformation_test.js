const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../transformation_library.js')+'');

describe('TRANSFORMATION unit tests', () => {

    it ('Version', async () => {
        assert.equal(transformationVersion(), '1.0.0');
    });

});
