import fs from 'fs';
import path from 'path';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';
import bundleSize from 'rollup-plugin-bundle-size';

// Find the input library file. The build invokes one rollup run per module
// (e.g. quadbin), passing FILENAME (e.g. quadbin.js) and DIRS (where to
// search for the entry-point libs file).
let input;
const dirs = process.env.DIRS.split(',');
const filename = process.env.FILENAME;
for (const dir of dirs) {
    const filepath = path.join(dir, filename);
    if (fs.existsSync(filepath)) {
        input = filepath;
        break;
    }
}
if (!input && filename) {
    console.error(
        `Error: library "${filename}" does not exist. Add it under libs/ or revisit ` +
        `the placeholder "@@ORA_LIBRARY_${path.parse(filename).name.toUpperCase()}@@" ` +
        'in one of your sql files.'
    );
    process.exit(1);
}

// Default output format is ES module (used for Oracle MLE — accepts ES
// modules with named exports). For Jest unit tests set UNIT_TEST=1 to
// produce a UMD bundle that's loadable via Node `require()`.
const isUnitTest = !!process.env.UNIT_TEST;
const baseName = path.parse(process.env.OUTPUT).name;
// Camel-case the lib name for the UMD global, e.g. quadbin → quadbinLib.
const umdName = baseName.replace(/(_\w)/g, k => k[1].toUpperCase()) + 'Lib';

export default {
    input,
    output: {
        file: process.env.OUTPUT,
        format: isUnitTest ? 'umd' : 'es',
        ...(isUnitTest ? { name: umdName } : {})
    },
    plugins: [
        resolve(),
        commonjs({ requireReturnsDefault: 'auto' }),
        json(),
        terser(),
        bundleSize()
    ],
    onwarn (warning, rollupWarn) {
        if (!['CIRCULAR_DEPENDENCY', 'THIS_IS_UNDEFINED'].includes(warning.code)) {
            rollupWarn(warning);
        }
    }
};