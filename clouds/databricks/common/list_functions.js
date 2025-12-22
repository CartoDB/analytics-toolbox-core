#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff="clouds/databricks/modules/test/quadbin/test_QUADBIN_TOZXY.py"
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const inputDir = '.';
const diff = argv.diff || [];
let modulesFilter = (argv.modules && argv.modules.split(',')) || [];
let functionsFilter = (argv.functions && argv.functions.split(',')) || [];
let all = !(diff.length || modulesFilter.length || functionsFilter.length);

// Track if modules came from diff (not explicitly requested)
// Modules from diff may not have tests (e.g., infrastructure modules like gateway)
// Explicitly requested modules should be validated
let modulesFromDiff = false;

// Convert diff to modules/functions
if (diff.length) {
    process.stderr.write(`DEBUG: Parsing diff (length=${diff.length})...\n`);
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
    process.stderr.write(`DEBUG: Checking patternsAll: ${diffAll}\n`);
    if (diffAll) {
        all = diffAll;
        process.stderr.write(`DEBUG: Matched patternsAll, setting all=true\n`);
    } else {
        process.stderr.write(`DEBUG: Matching SQL pattern...\n`);
        const modulesSql = [...diff.matchAll(patternModulesSql)].map(m => m[1]);
        process.stderr.write(`DEBUG: SQL modules found: ${JSON.stringify(modulesSql)}\n`);
        process.stderr.write(`DEBUG: Matching test pattern...\n`);
        const modulesTest = [...diff.matchAll(patternModulesTest)].map(m => m[1]);
        process.stderr.write(`DEBUG: Test modules found: ${JSON.stringify(modulesTest)}\n`);
        const diffModulesFilter = [...new Set(modulesSql.concat(modulesTest))];
        process.stderr.write(`DEBUG: Combined unique modules: ${JSON.stringify(diffModulesFilter)}\n`);
        if (diffModulesFilter) {
            modulesFilter = diffModulesFilter;
            modulesFromDiff = true;
            process.stderr.write(`DEBUG: Set modulesFilter and modulesFromDiff=true\n`);
        }
    }
}

// Debug output
process.stderr.write(`\n========== DEBUG LIST_FUNCTIONS.JS ==========\n`);
process.stderr.write(`DEBUG: Raw argv.diff type: ${typeof diff}\n`);
process.stderr.write(`DEBUG: Raw argv.diff length: ${diff.length}\n`);
process.stderr.write(`DEBUG: First 200 chars of diff: "${diff.substring(0, 200)}"\n`);
process.stderr.write(`DEBUG: Full diff: "${diff}"\n`);
process.stderr.write(`DEBUG: modulesFilter: ${JSON.stringify(modulesFilter)}\n`);
process.stderr.write(`DEBUG: modulesFromDiff: ${modulesFromDiff}\n`);
process.stderr.write(`DEBUG: all: ${all}\n`);

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

process.stderr.write(`DEBUG: Found ${functions.length} test functions in total\n`);
process.stderr.write(`DEBUG: Test modules found in filesystem: ${[...new Set(functions.map(f => f.module))].join(', ')}\n`);
process.stderr.write(`DEBUG: Functions by module:\n`);
const fnsByModule = {};
functions.forEach(f => {
    if (!fnsByModule[f.module]) fnsByModule[f.module] = [];
    fnsByModule[f.module].push(f.name);
});
Object.keys(fnsByModule).forEach(mod => {
    process.stderr.write(`  - ${mod}: ${fnsByModule[mod].join(', ')}\n`);
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
    const reason = all ? 'all=true' :
                   functionsFilter.includes(f.name) ? 'in functionsFilter' :
                   modulesFilter.includes(f.module) ? 'in modulesFilter' : 'not matched';
    process.stderr.write(`DEBUG: Function ${f.name} (module: ${f.module}): include=${include} (${reason})\n`);
    if (include) {
        output.push(f.fullPath);
    }
}
functions.forEach(f => filter(f));

process.stderr.write(`\nDEBUG: Final output: ${output.length} test files\n`);
process.stderr.write(`DEBUG: Test files to run:\n`);
output.forEach(f => process.stderr.write(`  - ${f}\n`));
process.stderr.write(`========================================\n\n`);
process.stdout.write(output.join(' '));