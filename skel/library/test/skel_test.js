const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../skel_library.js')+'');

describe('SKEL unit tests', () => {

    it ('Version', async () => {
        assert.equal(skelVersion(), 1);
    });
    
    it ('Adds stuff', async () => {
        assert.equal(skelExampleAdd(1), 2);
    });
});
