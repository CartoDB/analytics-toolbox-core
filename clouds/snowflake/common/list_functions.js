#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff="clouds/snowflake/modules/test/quadbin/QUADBIN_TOZXY.test.js"
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const modulename = argv._[0];
const moduledir = path.resolve('test', modulename);
const diff = argv.diff || [];
let modulesFilter = (argv.modules && argv.modules.split(',')) || [];
let functionsFilter = (argv.functions && argv.functions.split(',')) || [];
let all = !(diff.length || modulesFilter.length || functionsFilter.length);

// Convert diff to modules/functions
if (diff.length) {
    const patternsAll = [
        /\.github\/workflows\/snowflake\.yml/,
        /clouds\/snowflake\/common\/.+/,
        /clouds\/snowflake\/libraries\/.+/,
        /clouds\/snowflake\/.*Makefile/,
        /clouds\/snowflake\/version/,
        /clouds\/snowflake\/.*package\.json/
    ];
    const patternModulesSql = /clouds\/snowflake\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/snowflake\/modules\/test\/([^\s]*?)\//g;
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

// Extract functions
const functions = [];
if (fs.statSync(moduledir).isDirectory()) {
    const files = fs.readdirSync(moduledir);
    files.forEach(file => {
        pfile = path.parse(file);
        if (file.endsWith('.test.js')) {
            const name = pfile.name.replace('.test', '');
            functions.push({
                name,
                module: modulename,
                fullPath: path.join(moduledir, file)
            });
        }
    });
}

// Filter functions
const output = [];
function add (f) {
    const include = all || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
    if (include) {
        output.push(f.fullPath);
    }
}
functions.forEach(f => add(f));

if (output.length) {
    // Check global setup
    const setupfile = path.join(moduledir, 'global', 'setup.js');
    if (fs.existsSync(setupfile)) {
        output.push(`--globalSetup=${setupfile}`)
    }
    // Check global teardown
    const teardownfile = path.join(moduledir, 'global', 'teardown.js');
    if (fs.existsSync(teardownfile)) {
        output.push(`--globalTeardown=${teardownfile}`)
    }
}

process.stdout.write(output.join(' '));