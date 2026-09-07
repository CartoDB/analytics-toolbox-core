import fs from 'fs';
import path from 'path';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';
import bundleSize from 'rollup-plugin-bundle-size';

// Find final input path from dirs array
let input;
const dirs = process.env.DIRS.split(',');
const filename = process.env.FILENAME;
for (let dir of dirs) {
    const filepath = path.join(dir, filename);
    if (fs.existsSync(filepath)) {
        input = filepath;
        break;
    }
}

if (!input && filename) {
    console.log(`Error: library "${filename}" does not exist. Add it or revisit the replacement "@@SF_LIBRARY_${path.parse(filename).name.toUpperCase()}@@" in one of your sql files.`);
    process.exit(1);
}

// Format library name to camel case
const name = process.env.NAME.replace(/(_\w)/g, k => k[1].toUpperCase());

export default {
    input,
    output: {
        file: process.env.OUTPUT,
        sourcemap: process.env.SOURCEMAP === '1',
        sourcemapPathTransform: (relativeSourcePath, sourcemapPath) => {
            // Re-root sources at the repo directory: the defaults are relative to the map and leak the build layout
            const absolutePath = path.resolve(path.dirname(sourcemapPath), relativeSourcePath);
            const marker = `${path.sep}clouds${path.sep}`;
            const index = absolutePath.lastIndexOf(marker);
            if (index === -1) {
                return relativeSourcePath;
            }
            const root = absolutePath.slice(0, index).split(path.sep).pop();
            return [root, ...absolutePath.slice(index + 1).split(path.sep)].join('/');
        },
        format: process.env.UNIT_TEST ? 'umd': 'iife',
        name: process.env.UNIT_TEST ? name : '_' + name,
        banner: process.env.UNIT_TEST ? '' : 'if (typeof(' +name +') === "undefined") {',
        footer: process.env.UNIT_TEST ? '' : name +' = _' + name + ';}'
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