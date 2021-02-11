const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../quadkey_library.js')+'');

describe('QUADKEY unit tests', () => {

    it ('Version', async () => {
        assert.equal(quadkeyVersion(), 1);
    });
    
});
