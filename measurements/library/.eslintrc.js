module.exports = {
    env: {
        commonjs: false,
        es2020: true,
        node: false
    },
    extends: ['standard'],
    parserOptions: {
        ecmaVersion: 11,
        sourceType: "script"
    },
    rules: {
        "brace-style": ["error", "1tbs"],
        // We accept camelcase properties since the input JSONs have them and its easier to keep them as is
        "camelcase": ["error", { "properties": "never", "ignoreGlobals": true }],
        "indent": ["error", 4],
        "max-len": ["error", { "code": 120, "tabWidth": 4, "ignoreComments": true, "ignoreUrls": true, "ignoreStrings": true, "ignoreTemplateLiterals": true, "ignoreRegExpLiterals": true }],
        // Undefinition are allowed since files are checked individually, and functions might be declared in previous ones
        "no-undef": ["off"],
        "semi": ["error", "always"],
        "space-before-function-paren": ["error", "never"]
    }
};
