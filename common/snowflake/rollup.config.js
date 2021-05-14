import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';
import bundleSize from 'rollup-plugin-bundle-size';

export default {
    input: 'lib/index.js',
    output: {
        file: 'dist/index.js',
        format: process.env.UNIT_TEST ? 'umd': 'iife',
        name: 'lib'
    },
    plugins: [
        resolve(),
        commonjs(),
        json(),
        terser(),
        bundleSize()
    ],
    onwarn(warning, rollupWarn) {
        if (warning.code !== 'CIRCULAR_DEPENDENCY') {
            rollupWarn(warning);
        }
    }
};