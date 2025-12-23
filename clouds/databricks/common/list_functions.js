#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff="clouds/databricks/modules/test/quadbin/test_QUADBIN_TOZXY.py"
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDir = '.';
const diff = argv.diff || '';
let modulesFilter = (argv.modules && argv.modules.split(',')) || [];
let functionsFilter = (argv.functions && argv.functions.split(',')) || [];
let all = !(diff.length || modulesFilter.length || functionsFilter.length);

// Track if modules came from diff (not explicitly requested)
// Modules from diff may not have tests (e.g., infrastructure modules like gateway)
// Explicitly requested modules should be validated
let modulesFromDiff = false;

// Convert diff to modules/functions
if (diff.length) {
    const patternsAll = [
        /\.github\/workflows\/databricks\.yml/,
        /clouds\/databricks\/common\/.+/,
        /clouds\/databricks\/libraries\/.+/,
        /clouds\/databricks\/.*Makefile/,
        /clouds\/databricks\/version/
    ];
    const patternModulesSql = /clouds\/databricks\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/databricks\/modules\/test\/([^\s]*?)\//g;
    const diffAll = patternsAll.some(p => diff.match(p));
    if (diffAll) {
        all = diffAll;
    } else {
        const modulesSql = [...diff.matchAll(patternModulesSql)].map(m => m[1]);
        const modulesTest = [...diff.matchAll(patternModulesTest)].map(m => m[1]);
        const diffModulesFilter = [...new Set(modulesSql.concat(modulesTest))];
        if (diffModulesFilter) {
            modulesFilter = diffModulesFilter;
            modulesFromDiff = true;
        }
    }
}

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

// Check filters
// Only validate explicitly requested modules (not modules from diff)
// Modules from diff may be infrastructure modules without tests (e.g., gateway)
if (!modulesFromDiff) {
    modulesFilter.forEach(m => {
        if (!functions.map(fn => fn.module).includes(m)) {
            process.stderr.write(`ERROR: Module not found ${m}\n`);
            process.exit(1);
        }
    });
}
functionsFilter.forEach(f => {
    if (!functions.map(fn => fn.name).includes(f)) {
        process.stderr.write(`ERROR: Function not found ${f}\n`);
        process.exit(1);
    }
});

// Filter functions
const output = [];
function filter (f) {
    const include = all || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
    if (include) {
        output.push(f.fullPath);
    }
}
functions.forEach(f => filter(f));

process.stdout.write(output.join(' '));