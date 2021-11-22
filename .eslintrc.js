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
        'dist/*',
        '*fixture*',
        '*custom*'
    ],
    rules: {
        'comma-dangle': ['error', 'never'],
        'eol-last': ['error', 'never'],
        'indent': ['error', 4],
        'keyword-spacing': ['error', { before: true }],
        'no-path-concat': ['off'],
        'no-undef': ['off'],
        'no-unused-vars': ['off'],
        'object-curly-spacing': ['error', 'always'],
        'quotes': ['error', 'single', 'avoid-escape'],
        'space-before-function-paren': ['error', 'always']
    }
};