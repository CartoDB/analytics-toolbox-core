module.exports = {
    env: {
        commonjs: true,
        es2020: true,
        node: true,
        jest: true
    },
    extends: [
        'eslint:recommended'
    ],
    parserOptions: {
        ecmaVersion: 11,
        sourceType: 'module'
    },
    ignorePatterns: [
        'dist/*'
    ],
    rules: {
        quotes: ['error', 'single'],
        indent: ['error', 4],
        'comma-dangle': ['error', 'never'],
        'no-path-concat': ['off']
    }
};
