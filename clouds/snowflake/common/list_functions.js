#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff="clouds/snowflake/modules/test/quadbin/QUADBIN_TOZXY.test.js"
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin
// ./list_functions.js h3 --type=benchmark --functions=H3_KRING

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const modulename = argv._[0];
// type=test (default) scans test/<module>/<FUNCTION>.test.js
// type=benchmark scans benchmark/<module>/<FUNCTION>.bench.js
const type = argv.type === 'benchmark' ? 'benchmark' : 'test';
// --base-dirs="p1,p2" scans each base dir; defaults to CWD.
const baseDirs = argv['base-dirs']
    ? argv['base-dirs'].split(',').map(s => s.trim()).filter(Boolean)
    : ['.'];
const fileExtension = type === 'benchmark' ? '.bench.js' : '.test.js';
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

// Extract functions across all base dirs.
const functions = [];
const moduledirs = baseDirs.map(b => path.resolve(b, type, modulename));
moduledirs.forEach(moduledir => {
    if (!fs.existsSync(moduledir) || !fs.statSync(moduledir).isDirectory()) return;
    const files = fs.readdirSync(moduledir);
    files.forEach(file => {
        const pfile = path.parse(file);
        if (file.endsWith(fileExtension)) {
            // strip both .test.js and .bench.js compound extensions
            const name = pfile.name.replace(/\.(test|bench)$/, '');
            functions.push({
                name,
                module: modulename,
                fullPath: path.join(moduledir, file)
            });
        }
    });
});

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
    // Check global setup/teardown across base dirs (first match wins).
    for (const moduledir of moduledirs) {
        const setupfile = path.join(moduledir, 'global', 'setup.js');
        if (fs.existsSync(setupfile)) {
            output.push(`--globalSetup=${setupfile}`);
            break;
        }
    }
    for (const moduledir of moduledirs) {
        const teardownfile = path.join(moduledir, 'global', 'teardown.js');
        if (fs.existsSync(teardownfile)) {
            output.push(`--globalTeardown=${teardownfile}`);
            break;
        }
    }
}

process.stdout.write(output.join(' '));