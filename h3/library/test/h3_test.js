const test = require('tape');
const fs = require('fs');
/* Emulate how BigQuery would load the file */
global.eval(fs.readFileSync('./h3_version.js') + '');

test('Version', assert => {
    assert.equal(h3Version(), '3.7.0.1');
    assert.end();
});