import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';

export default {
    input: 'lib/index.js',
    output: {
        file: 'dist/index.js',
        format: 'umd',
        name: 'lib'
    },
    plugins: [
        resolve(),
        commonjs(),
        json(),
        terser()
    ]
};