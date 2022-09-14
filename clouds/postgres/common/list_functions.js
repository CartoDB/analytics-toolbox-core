#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff=quadbin/test/test_QUADBIN_TOZXY.py
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDir = '.';
const diff = argv.diff || [];
const modulesFilter = (argv.modules && argv.modules.split(',')) || [];
const functionsFilter = (argv.functions && argv.functions.split(',')) || [];
const all = !(diff.length || modulesFilter.length || functionsFilter.length);

// Extract functions
const functions = [];
const testdir = path.join(inputDir, 'test');
const modules = fs.readdirSync(testdir);
modules.forEach(module => {
    const moduledir = path.join(testdir, module);
    if (fs.statSync(moduledir).isDirectory()) {
        const files = fs.readdirSync(moduledir);
        files.forEach(file => {
            pfile = path.parse(file);
            if (pfile.name.startsWith('test_') && pfile.ext === '.py') {
                const name = pfile.name.substring(5);
                functions.push({
                    name,
                    module,
                    fullPath: path.join(moduledir, file)
                });
            }
        });
    }
});

// Filter functions
const output = [];
function filter (f) {
    const include = all || diff.includes(path.join(f.fullPath)) || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
    if (include) {
        output.push(f.fullPath);
    }
}
functions.forEach(f => filter(f));

process.stdout.write(output.join(' '));