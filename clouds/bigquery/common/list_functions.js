#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff=quadbin/test/QUADBIN_TOZXY.test.js
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const modulename = argv._[0];
const moduledir = path.resolve('test', modulename);
const diff = argv.diff || [];
const fileExtension = argv.extension || '.test.js';
const modulesFilter = (argv.modules && argv.modules.split(',')) || [];
const functionsFilter = (argv.functions && argv.functions.split(',')) || [];
const all = !(diff.length || modulesFilter.length || functionsFilter.length);

// Extract functions
const functions = [];
if (fs.statSync(moduledir).isDirectory()) {
    const files = fs.readdirSync(moduledir);
    files.forEach(file => {
        pfile = path.parse(file);
        if (file.endsWith(fileExtension)) {
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
    const include = all || diff.includes(path.join(f.fullPath)) || functionsFilter.includes(f.name) || modulesFilter.includes(f.module);
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
    if (fs.existsSync(setupfile)) {
        output.push(`--globalTeardown=${teardownfile}`)
    }
}

process.stdout.write(output.join(' '));