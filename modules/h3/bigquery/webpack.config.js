// const OptimizeWasmPlugin = require('optimize-wasm-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
// const ShakePlugin = require('webpack-common-shake').Plugin;



module.exports = {
    entry: './lib/index.js',
    output: {
        filename: 'main.js',
        libraryTarget: 'var',
        library: 'lib',
        globalObject: 'this',
        umdNamedDefine: true
        // globalObject: '(typeof self !== \'undefined\' ? self : this)'
    },
    externals: {
        document: 'document'
    },
    optimization: {
        usedExports: true,
        minimize: false,
        minimizer: [new TerserPlugin({
            parallel: 3
        })]
    }
};