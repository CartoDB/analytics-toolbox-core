const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../squelleton_library.js')+'');

describe('SQUELLETON unit tests', () => {

    it ('Version', async () => {
        assert.equal(squelletonVersion(), '1.0.0');
    });

});
