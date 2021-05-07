import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
// import { uglify } from 'rollup-plugin-uglify';


export default {
    input: 'lib/index.js',
    output: {
        file: 'dist/main.js',
        format: 'cjs',
        exports: 'named',
        compact: false
    },
    plugins: [
        resolve(),
        commonjs(),
        json()
        // uglify()
    ]
};