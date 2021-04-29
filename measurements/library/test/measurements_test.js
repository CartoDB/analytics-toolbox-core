const fs = require('fs');
const assert = require('assert').strict;
/* Emulate how BigQuery would load the file */
eval(fs.readFileSync('../../measurements_library.js')+'');

describe('MEASUREMENTS unit tests', () => {

    it ('Version', async () => {
        assert.equal(measurementsVersion(), '1.0.0');
    });
});
