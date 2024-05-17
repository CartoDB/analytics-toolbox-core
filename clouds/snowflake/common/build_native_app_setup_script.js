#!/usr/bin/env node

// Build the setup_script for the native app installer setup file

// ./build_native_app_setup_script.js modules --output=build --libs_build_dir=../libraries/javascript/build native_app_dir=../native_app --production --dropfirst

const fs = require('fs');
const path = require('path');
const argv = require('minimist')(process.argv.slice(2));

const outputDir = argv.output || 'build';
const libsBuildDir = argv.libs_build_dir || '../libraries/javascript/build';
const nativeAppDir = argv.native_app_dir || '../native_app';

// Replace environment variables
let separator;
if (argv.production) {
    separator = '\n';
} else {
    separator = '\n-->\n';  // marker to future SQL split
}
let content = fs.readFileSync(path.resolve(nativeAppDir, 'SETUP_SCRIPT.sql')).toString();

function apply_replacements (text) {
    const libraries = [... new Set(text.match(new RegExp('@@SF_LIBRARY_.*@@', 'g')))];
    for (let library of libraries) {
        const libraryName = library.replace('@@SF_LIBRARY_', '').replace('@@', '').toLowerCase() + '.js';
        const libraryPath = path.join(libsBuildDir, libraryName);
        if (fs.existsSync(libraryPath)) {
            const libraryContent = fs.readFileSync(libraryPath).toString();
            text = text.replace(new RegExp(library, 'g'), libraryContent);
        }
        else {
            console.log(`Warning: library "${libraryName}" does not exist. Run "make build-libraries" with the same filters.`);
            process.exit(1);
        }
    }
    const replacements = process.env.REPLACEMENTS.split(' ');
    for (let replacement of replacements) {
        if (replacement) {
            const pattern = new RegExp(`@@${replacement}@@`, 'g');
            text = text.replace(pattern, process.env[replacement]);
        }
    }
    return text;
}

if (argv.dropfirst) {
    let header = fs.readFileSync(path.resolve(__dirname, 'DROP_FUNCTIONS.sql')).toString();
    const pattern = new RegExp('@@SF_SCHEMA@@', 'g');
    header = header.replace(pattern, '@@SF_APP_SCHEMA@@');
    content = header + separator + content
}

const header = `CREATE OR REPLACE APPLICATION ROLE @@APP_ROLE@@;
CREATE OR ALTER VERSIONED SCHEMA @@SF_APP_SCHEMA@@;
GRANT USAGE ON SCHEMA @@SF_APP_SCHEMA@@ TO APPLICATION ROLE @@APP_ROLE@@;\n`;

let additionalTables = '';
if (argv.production) {
    additionalTables = fs.readFileSync(path.resolve(nativeAppDir, 'ADDITIONAL_TABLES.sql')).toString() + separator;
}

content = header + separator + additionalTables + content;

content = apply_replacements(content);

// Write setup_script.sql file
fs.writeFileSync(path.join(outputDir, 'setup_script.sql'), content);
console.log(`Write ${outputDir}/setup_script.sql`);