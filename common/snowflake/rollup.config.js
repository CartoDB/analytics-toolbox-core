import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';
import { terser } from 'rollup-plugin-terser';
import bundleSize from 'rollup-plugin-bundle-size';

export default {
    input: process.env.LIB_DIR,
    output: {
        file: process.env.DIST_DIR,
        format: process.env.UNIT_TEST ? 'umd': 'iife',
        name: process.env.UNIT_TEST ? process.env.NAME : '_' + process.env.NAME,
        banner: process.env.UNIT_TEST ? '' : 'if (typeof(' + process.env.NAME +') === "undefined") {',
        footer: process.env.UNIT_TEST ? '' : process.env.NAME +' = _' + process.env.NAME + ';}'
    },
    plugins: [
        resolve(),
        commonjs({ requireReturnsDefault: 'auto' }),
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