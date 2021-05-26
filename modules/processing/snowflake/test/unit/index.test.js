const processingLib = require('../../dist/index');
const version = require('../../package.json').version;

test('processing library defined', () => {
    expect(processingLib.version).toBe(version);
});