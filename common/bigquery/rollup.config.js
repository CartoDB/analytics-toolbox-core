import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';
import bundleSize from 'rollup-plugin-bundle-size';

export default {
    input: 'lib/index.js',
    output: {
        file: 'dist/index.js',
        format: process.env.UNIT_TEST ? 'umd' : 'iife',
        name: process.env.NAME
    },
    plugins: [
        resolve(),
        commonjs({ requireReturnsDefault: 'auto' }),
        json(),
        terser(),
        bundleSize()
    ],
    onwarn (warning, rollupWarn) {
        if (!['CIRCULAR_DEPENDENCY', 'MISSING_NODE_BUILTINS'].includes(warning.code)) {
            rollupWarn(warning);
        }
    }
};