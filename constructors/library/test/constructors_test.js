const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../constructors_library.js')+'');

describe('CONSTRUCTORS unit tests', () => {

    it ('Version', async () => {
        assert.equal(constructorsVersion(), '1.0.0');
    });
});
