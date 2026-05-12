#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff="clouds/postgres/modules/test/quadbin/test_QUADBIN_TOZXY.py"
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin
// ./list_functions.js --type=benchmark --modules=h3 --functions=H3_KRING

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

// --base-dirs="p1,p2" scans each base dir; defaults to CWD.
const baseDirs = argv['base-dirs']
    ? argv['base-dirs'].split(',').map(s => s.trim()).filter(Boolean)
    : ['.'];
const diff = argv.diff || [];
let modulesFilter = (argv.modules && argv.modules.split(',')) || [];
let functionsFilter = (argv.functions && argv.functions.split(',')) || [];
let all = !(diff.length || modulesFilter.length || functionsFilter.length);

// type=test (default) scans modules/test/<module>/test_<FUNCTION>.py
// type=benchmark scans modules/benchmark/<module>/benchmark_<FUNCTION>.py
const type = argv.type === 'benchmark' ? 'benchmark' : 'test';
const subdir = type === 'benchmark' ? 'benchmark' : 'test';
const filePrefix = type === 'benchmark' ? 'benchmark_' : 'test_';

// Convert diff to modules/functions
if (diff.length) {
    const patternsAll = [
        /\.github\/workflows\/postgres\.yml/,
        /clouds\/postgres\/common\/.+/,
        /clouds\/postgres\/libraries\/.+/,
        /clouds\/postgres\/.*Makefile/,
        /clouds\/postgres\/version/
    ];
    const patternModulesSql = /clouds\/postgres\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/postgres\/modules\/test\/([^\s]*?)\//g;
    const diffAll = patternsAll.some(p => diff.match(p));
    if (diffAll) {
        all = diffAll;
    } else {
        const modulesSql = [...diff.matchAll(patternModulesSql)].map(m => m[1]);
        const modulesTest = [...diff.matchAll(patternModulesTest)].map(m => m[1]);
        const diffModulesFilter = [...new Set(modulesSql.concat(modulesTest))];
        if (diffModulesFilter) {
            modulesFilter = diffModulesFilter;
        }
    }
}

// Extract functions across all base dirs.
const functions = [];
function upsert (entry) {
    const idx = functions.findIndex(f => f.name === entry.name && f.module === entry.module);
    if (idx >= 0) functions[idx] = entry;
    else functions.push(entry);
}
baseDirs.forEach(baseDir => {
    const scandir = path.resolve(baseDir, subdir);
    if (!fs.existsSync(scandir)) return;
    const modules = fs.readdirSync(scandir);
    modules.forEach(module => {
        const moduledir = path.join(scandir, module);
        if (!fs.statSync(moduledir).isDirectory()) return;
        const files = fs.readdirSync(moduledir);
        files.forEach(file => {
            const pfile = path.parse(file);
            if (pfile.name.startsWith(filePrefix) && pfile.ext === '.py') {
                upsert({
                    name: pfile.name.substring(filePrefix.length),
                    module,
                    fullPath: path.join(moduledir, file)
                });
            }
        });
    });
});

// Check filters
modulesFilter.forEach(m => {
    if (!functions.map(fn => fn.module).includes(m)) {
        process.stderr.write(`ERROR: Module not found ${m}\n`);
        process.exit(1);
    }
});
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