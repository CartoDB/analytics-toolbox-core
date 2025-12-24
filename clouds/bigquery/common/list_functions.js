#!/usr/bin/env node

// List the functions based on the input filters

// ./list_functions.js --diff="clouds/bigquery/modules/test/quadbin/QUADBIN_TOZXY.test.js"
// ./list_functions.js --functions=ST_TILEENVELOPE
// ./list_functions.js --modules=quadbin

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const modulename = argv._[0];
const moduledir = path.resolve('test', modulename);
let diff = argv.diff || [];

// Parse JSON format from get-diff-action v6
if (typeof diff === 'string' && diff.length > 0) {
    const trimmed = diff.trim();

    // Always log diff input for debugging (will help identify issues)
    console.error('[DIFF-DEBUG] Input type:', typeof diff, '| length:', diff.length, '| first 100 chars:', diff.substring(0, 100));

    if (trimmed.startsWith('[')) {
        try {
            const parsed = JSON.parse(trimmed);
            if (Array.isArray(parsed)) {
                const original = diff;
                diff = parsed.join(' ');
                console.error('[DIFF-DEBUG] Parsed JSON array with', parsed.length, 'files → converted to space-separated string');
            } else {
                console.error('[WARN] JSON parsed but not an array:', typeof parsed);
            }
        } catch (e) {
            console.error('[WARN] JSON parse failed:', e.message, '| treating as legacy format');
        }
    } else {
        console.error('[DIFF-DEBUG] Not JSON format (doesn\'t start with [), using as legacy format');
    }
} else if (diff === '') {
    console.error('[DIFF-DEBUG] Empty diff - will build all');
} else {
    console.error('[DIFF-DEBUG] No diff provided (type:', typeof diff, ') - will build all');
}

const fileExtension = argv.fileExtension || '.test.js';
let modulesFilter = (argv.modules && argv.modules.split(',')) || [];
let functionsFilter = (argv.functions && argv.functions.split(',')) || [];
let all = !(diff.length || modulesFilter.length || functionsFilter.length);

// Convert diff to modules
if (diff.length) {
    const patternsAll = [
        /\.github\/workflows\/bigquery\.yml/,
        /clouds\/bigquery\/common\/.+/,
        /clouds\/bigquery\/libraries\/.+/,
        /clouds\/bigquery\/.*Makefile/,
        /clouds\/bigquery\/version/,
        /clouds\/bigquery\/.*package\.json/
    ];
    const patternModulesSql = /clouds\/bigquery\/modules\/sql\/([^\s]*?)\//g;
    const patternModulesTest = /clouds\/bigquery\/modules\/test\/([^\s]*?)\//g;
    const diffAll = patternsAll.some(p => diff.match(p));

    console.error('[DIFF-DEBUG] Checking patterns against diff...');
    if (diffAll) {
        console.error('[DIFF-DEBUG] ✓ Matched "build all" pattern - will test ALL modules');
        all = diffAll;
    } else {
        const modulesSql = [...diff.matchAll(patternModulesSql)].map(m => m[1]);
        const modulesTest = [...diff.matchAll(patternModulesTest)].map(m => m[1]);
        const diffModulesFilter = [...new Set(modulesSql.concat(modulesTest))];
        console.error('[DIFF-DEBUG] Extracted modules from diff:', diffModulesFilter.length > 0 ? diffModulesFilter.join(', ') : '(none)');
        if (diffModulesFilter) {
            modulesFilter = diffModulesFilter;
        }
    }
} else {
    console.error('[DIFF-DEBUG] Diff is empty, will test ALL modules');
}

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